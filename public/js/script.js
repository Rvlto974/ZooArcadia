// On attend que le HTML soit complètement chargé
document.addEventListener("DOMContentLoaded", function () {
    // On récupère le bouton
    const bouton = document.querySelector("#toggle-habitats");

    // On récupère la liste des habitats
    const listeHabitats = document.querySelector("#liste-habitats");

    // On vérifie que les éléments existent
    if (bouton && listeHabitats) {
        // On détecte le clic sur le bouton
        bouton.addEventListener("click", function () {
            // On ajoute ou retire la classe "cache"
            listeHabitats.classList.toggle("cache");

            // On modifie le texte du bouton
            if (listeHabitats.classList.contains("cache")) {
                bouton.textContent = "Afficher les habitats";
            } else {
                bouton.textContent = "Cacher les habitats";
            }
        });
    }
});