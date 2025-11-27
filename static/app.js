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

	// Bottom nav: mark active item on small screens
	const bnItems = document.querySelectorAll('.bottom-nav .bn-item');
	if (bnItems && bnItems.length) {
		const path = window.location.pathname || '/';
		// prefer the longest matching data-path
		let best = null;
		bnItems.forEach(item => {
			const dp = item.getAttribute('data-path') || '/';
			// simple match: path starts with dp
			if (path === dp || path.startsWith(dp)) {
				if (!best || dp.length > best.getAttribute('data-path').length) {
					best = item;
				}
			}
		});
		// fallback: root
		if (!best) {
			bnItems.forEach(item => { if (item.getAttribute('data-path') === '/') best = item; });
		}
		if (best) best.classList.add('active');
	}
});
