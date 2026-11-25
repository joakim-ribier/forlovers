# forlovers: the home page of www.forlovers.app. A static Astro site: built on the Mac, sent
# to the server with rsync, served by the server's nginx over HTTPS (Let's Encrypt).
# make help lists everything.

# The two names: www.forlovers.app is the address, forlovers.app sends to it.
DOMAIN := www.forlovers.app
APEX   := forlovers.app

# Where make deploy sends the site: .env's FORLOVERS_DEPLOY_HOST (an SSH alias), or HOST=…;
# into ~/forlovers on the server.
DEPLOY_HOST := $(or $(HOST),$(shell sed -n 's/^FORLOVERS_DEPLOY_HOST=//p' .env 2>/dev/null | tail -1))
DEPLOY_DIR  := forlovers

# On the server: the site and the nginx templates, as make deploy leaves them.
SITE_DIR := $(CURDIR)/dist/site
render = sed -e 's|@SITE_DIR@|$(SITE_DIR)|g' -e 's|@DOMAIN@|$(DOMAIN)|g' -e 's|@APEX@|$(APEX)|g' dist/deploy/$(1)

.DEFAULT_GOAL := help
.PHONY: help init deps dev build preview brand deploy install install-certificate install-nginx install-aliases status logs clean

help: ## cette liste
	@awk 'BEGIN {FS = ":.*##"} /^##@/ {printf "\n%s\n", substr($$0, 5)} /^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

##@ Sur le Mac

init: ## écrit .env : le serveur du deploy (son alias SSH) ; Entrée garde la valeur
	@./scripts/init.sh

deps: ## les dépendances, versions verrouillées (npm ci)
	npm ci

# The dependencies, installed the first time (and when the lock file changes).
node_modules/.package-lock.json: package-lock.json
	npm ci

dev: node_modules/.package-lock.json ## la page en dev, rechargée à chaque modification (http://localhost:4321)
	npm run dev

build: node_modules/.package-lock.json ## la page vérifiée (astro check) et construite → dist/
	npm run build

preview: build ## la page construite, servie comme en production (http://localhost:4321)
	npm run preview

brand: ## refait les PNG et le .ico du logo depuis brand/, et les recopie dans public/
	./brand/render.sh

deploy: build ## construit la page et l'envoie au serveur de .env -- ou HOST=… ; 1re fois, là-bas : make install
	@test -n "$(DEPLOY_HOST)" || { echo ">>> Aucun serveur : FORLOVERS_DEPLOY_HOST dans .env (make init), ou HOST=…"; exit 2; }
	@echo ">>> Vers $(DEPLOY_HOST):$(DEPLOY_DIR)"
	@# rsync and make on the server: installed only if one is missing.
	@ssh $(DEPLOY_HOST) 'command -v rsync > /dev/null && command -v make > /dev/null || { echo ">>> rsync ou make absent du serveur : installation"; sudo apt-get update -q && sudo apt-get install -y rsync make; }'
	ssh $(DEPLOY_HOST) "mkdir -p $(DEPLOY_DIR)/dist/site $(DEPLOY_DIR)/dist/deploy"
	rsync -az --delete dist/ $(DEPLOY_HOST):$(DEPLOY_DIR)/dist/site/
	rsync -az --delete deploy/ $(DEPLOY_HOST):$(DEPLOY_DIR)/dist/deploy/
	rsync -az Makefile $(DEPLOY_HOST):$(DEPLOY_DIR)/
	@echo ">>> Envoyé : en ligne tout de suite si make install a déjà été fait ; sinon, sur le serveur : cd $(DEPLOY_DIR) && make install"

##@ Serveur -- sur le serveur, dans ~/forlovers (la page est dans dist/site)

# Safe to run again and again: the certificate is asked for once, the nginx site is rewritten
# and tested before nginx reloads (the previous one put back if the test fails), the shortcuts
# line is added to ~/.bashrc once.
install: ## 1re fois, et quand deploy/ a changé : certificat HTTPS, site nginx, raccourcis ; sans risque à relancer
	@test -f dist/site/index.html || { echo ">>> Pas de page ici : depuis le Mac, make deploy d'abord"; exit 2; }
	@command -v nginx > /dev/null || sudo apt-get install -y nginx
	@$(MAKE) --no-print-directory install-certificate
	@$(MAKE) --no-print-directory install-nginx
	sudo systemctl reload nginx
	@$(MAKE) --no-print-directory install-aliases
	@echo ">>> En ligne : https://$(DOMAIN) (https://$(APEX) y renvoie) -- forlovers-help pour les raccourcis"

# The certificate (Let's Encrypt) for both names, by a file nginx serves on port 80: until it's
# there, nginx answers that alone for these names (forlovers-acme.nginx); certbot's timer
# renews it, nginx reloaded then. Needs both names' DNS on this server first.
install-certificate: ## certificat HTTPS de forlovers.app et www.forlovers.app, renouvelé tout seul
	@command -v certbot > /dev/null || sudo apt-get install -y certbot
	@if sudo test -f /etc/letsencrypt/live/$(APEX)/fullchain.pem; then echo ">>> Certificat déjà là ($(APEX), $(DOMAIN))"; else \
		sudo mkdir -p /var/www/letsencrypt && \
		$(call render,forlovers-acme.nginx) | sudo tee /etc/nginx/sites-available/forlovers > /dev/null && \
		sudo ln -sf /etc/nginx/sites-available/forlovers /etc/nginx/sites-enabled/forlovers && \
		sudo nginx -t && sudo systemctl reload nginx && \
		sudo certbot certonly --webroot -w /var/www/letsencrypt --cert-name $(APEX) -d $(APEX) -d $(DOMAIN) \
			--non-interactive --agree-tos --register-unsafely-without-email --deploy-hook "systemctl reload nginx"; fi

# The nginx site, tested before it stays: nginx may serve other sites, and a
# broken file left enabled would make their next reload fail too. On a failed test, the
# previous file is put back (or none, the first time) and nothing is reloaded.
NGINX_SITE := /etc/nginx/sites-available/forlovers
install-nginx: ## le site nginx de dist/deploy/ écrit dans /etc/nginx, testé (nginx -t) ; l'ancien remis si le test échoue
	@# nginx (www-data) through the home folder to dist/site -- closed to others on Debian 13 --,
	@# allowed to pass only, nothing listed; no other account gets in.
	@command -v setfacl > /dev/null || sudo apt-get install -y acl
	sudo setfacl -m u:www-data:x $(HOME)
	@if sudo test -f $(NGINX_SITE); then sudo cp -p $(NGINX_SITE) $(NGINX_SITE).previous; else sudo rm -f $(NGINX_SITE).previous; fi
	$(call render,forlovers-public.nginx) | sudo tee $(NGINX_SITE) > /dev/null
	sudo ln -sf $(NGINX_SITE) /etc/nginx/sites-enabled/forlovers
	@if sudo nginx -t; then sudo rm -f $(NGINX_SITE).previous; else \
		if sudo test -f $(NGINX_SITE).previous; then sudo mv $(NGINX_SITE).previous $(NGINX_SITE); \
		else sudo rm -f $(NGINX_SITE) /etc/nginx/sites-enabled/forlovers; fi; \
		echo ">>> Conf nginx refusée : l'ancienne est remise, rien n'est rechargé"; exit 1; fi

# One line in ~/.bashrc, added once: the forlovers-* shortcuts (deploy/aliases.sh) at every login.
ALIASES_LINE := [ -f $(CURDIR)/dist/deploy/aliases.sh ] && . $(CURDIR)/dist/deploy/aliases.sh
install-aliases: ## les raccourcis forlovers-* (forlovers-help) à chaque connexion
	@grep -qF '$(ALIASES_LINE)' ~/.bashrc 2>/dev/null \
		&& echo ">>> Raccourcis déjà chargés par ~/.bashrc (forlovers-help)" \
		|| { echo '$(ALIASES_LINE)' >> ~/.bashrc && echo ">>> Raccourcis ajoutés à ~/.bashrc -- nouvelle connexion, ou : . ~/.bashrc ; puis forlovers-help"; }

status: ## le site répond-il, et jusqu'à quand le certificat
	@curl -sS -o /dev/null -w "https://$(DOMAIN) : %{http_code}\n" https://$(DOMAIN)/ || true
	@sudo certbot certificates --cert-name $(APEX) 2>/dev/null | grep -E 'Domains|Expiry' || echo ">>> Pas de certificat $(APEX)"

logs: ## les visites et les erreurs du site, en direct (Ctrl+C)
	sudo tail -f /var/log/nginx/forlovers.access.log /var/log/nginx/forlovers.error.log

##@ Ménage

clean: ## supprime dist/ et .astro/
	rm -rf dist .astro
