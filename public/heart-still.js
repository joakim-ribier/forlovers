// Reduced motion: jump straight to the drawn heart and stop every animation.
// A file of its own, not an inline script, so the Content-Security-Policy can forbid inline scripts.
if (matchMedia('(prefers-reduced-motion: reduce)').matches) {
  for (const svg of document.querySelectorAll('svg.heart')) {
    svg.setCurrentTime(4.2);
    svg.pauseAnimations();
  }
}
