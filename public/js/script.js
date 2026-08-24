// On attend que le HTML soit complètement chargé
document.addEventListener("DOMContentLoaded", function () {

    // =========================
    // Afficher / cacher les habitats
    // =========================

    const bouton = document.querySelector("#toggle-habitats");
    const listeHabitats = document.querySelector("#liste-habitats");

    if (bouton && listeHabitats) {
        bouton.addEventListener("click", function () {
            listeHabitats.classList.toggle("cache");

            if (listeHabitats.classList.contains("cache")) {
                bouton.textContent = "Afficher les habitats";
            } else {
                bouton.textContent = "Cacher les habitats";
            }
        });
    }

    // =========================
    // Animation des éléments au défilement
    // =========================

    const elements = document.querySelectorAll(".animation-scroll");

    const observer = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (entry.isIntersecting) {
                entry.target.classList.add("visible");
            }
        });
    }, {
        threshold: 0.2
    });

    elements.forEach(function (element) {
        observer.observe(element);
    });
});