// Funciones compartidas para la UI (incluye control de menú móvil)
document.addEventListener('DOMContentLoaded', function() {
	console.log('Catálogo Web cargado correctamente');

	// Mobile nav toggle
	const navToggle = document.querySelector('.nav-toggle');
	const navLinks = document.querySelector('.nav-links');

	if (navToggle && navLinks) {
		navToggle.addEventListener('click', function(e) {
			const open = navLinks.classList.toggle('open');
			navToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
		});

		// Close menu when a nav link is clicked (mobile)
		navLinks.querySelectorAll('a').forEach(a => {
			a.addEventListener('click', () => {
				if (navLinks.classList.contains('open')) {
					navLinks.classList.remove('open');
					navToggle.setAttribute('aria-expanded', 'false');
				}
			});
		});

		// Close menu when clicking outside (mobile)
		document.addEventListener('click', (e) => {
			if (!navLinks.contains(e.target) && !navToggle.contains(e.target)) {
				if (navLinks.classList.contains('open')) {
					navLinks.classList.remove('open');
					navToggle.setAttribute('aria-expanded', 'false');
				}
			}
		});
	}
});
