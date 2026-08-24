// Attend que toute la page HTML soit chargée
document.addEventListener("DOMContentLoaded", function () {
    // Récupère toutes les cartes d'habitat
    const cartesHabitats = document.querySelectorAll(".habitat-card");

    // Ajoute un clic sur chaque carte
    cartesHabitats.forEach(function (carte) {
        carte.addEventListener("click", function () {
            // Ouvre ou ferme les détails de la carte
            carte.classList.toggle("active");
        });
    });

    // Récupère le bouton d'affichage des habitats
    const boutonHabitats = document.querySelector("#toggle-habitats");

    // Récupère le conteneur des cartes
    const conteneurHabitats = document.querySelector("#habitats-container");

    // Vérifie que les éléments existent avant d'ajouter le clic
    if (boutonHabitats && conteneurHabitats) {
        boutonHabitats.addEventListener("click", function () {
            // Affiche ou cache les cartes
            conteneurHabitats.classList.toggle("cache");

            // Change le texte du bouton
            if (conteneurHabitats.classList.contains("cache")) {
                boutonHabitats.textContent = "Afficher les habitats";
            } else {
                boutonHabitats.textContent = "Masquer les habitats";
            }
        });
    }
});