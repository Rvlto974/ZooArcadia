// On attend que toute la page HTML soit chargée
document.addEventListener("DOMContentLoaded", function () {

    // On récupère le bouton "Découvrir le zoo"
    const bouton = document.querySelector(".btn-primary");

    // On vérifie que le bouton existe
    if (bouton) {
        bouton.addEventListener("click", function (event) {

            // Empêche le comportement automatique du lien
            event.preventDefault();

            // On récupère la section presentation
            const presentation = document.querySelector("#presentation");

            // On fait défiler doucement vers cette section
            if (presentation) {
                presentation.scrollIntoView({
                    behavior: "smooth"
                });
            }
        });
    }

    // Message de vérification dans la console
    console.log("Le fichier JavaScript fonctionne !");
});