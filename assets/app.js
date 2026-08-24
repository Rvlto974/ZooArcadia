document.addEventListener("DOMContentLoaded", function () {
    console.log("JavaScript chargé");

    // Animation au défilement
    const elements = document.querySelectorAll(
        ".hero, .presentation, .habitats, .services, .contact, .card"
    );

    if ("IntersectionObserver" in window) {
        const observateur = new IntersectionObserver(function (entrees, observer) {
            entrees.forEach(function (entree) {
                if (entree.isIntersecting) {
                    entree.target.classList.add("visible");
                    observer.unobserve(entree.target);
                }
            });
        }, {
            threshold: 0.15
        });

        elements.forEach(function (element) {
            observateur.observe(element);
        });
    } else {
        elements.forEach(function (element) {
            element.classList.add("visible");
        });
    }

    // Afficher ou cacher les détails des cartes
    const cartes = document.querySelectorAll(".habitat-card");

    cartes.forEach(function (carte) {
        carte.addEventListener("click", function () {
            carte.classList.toggle("active");
        });
    });
});