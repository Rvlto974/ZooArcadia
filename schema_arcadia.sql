-- ============================================================================
-- Projet-Zoo-Arcadia - Schéma MySQL complet
-- Exécution : mysql -u root -p arcadia < schema_arcadia.sql
-- Compatible MySQL 8.0+ (InnoDB / utf8mb4)
-- ============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Suppression idempotente : enfants avant parents.
DROP TABLE IF EXISTS `alimentations`;
DROP TABLE IF EXISTS `rapports_veterinaires`;
DROP TABLE IF EXISTS `images`;
DROP TABLE IF EXISTS `avis`;
DROP TABLE IF EXISTS `contacts`;
DROP TABLE IF EXISTS `animaux`;
DROP TABLE IF EXISTS `services`;
DROP TABLE IF EXISTS `races`;
DROP TABLE IF EXISTS `habitats`;
DROP TABLE IF EXISTS `utilisateurs`;

SET FOREIGN_KEY_CHECKS = 1;

-- Utilisateurs du back-office : employés, vétérinaires et administrateurs.
CREATE TABLE `utilisateurs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `nom` VARCHAR(100) NOT NULL,
    `prenom` VARCHAR(100) NOT NULL,
    `email` VARCHAR(255) NOT NULL,
    `mot_de_passe` VARCHAR(255) NOT NULL,
    `role` ENUM('employe', 'veterinaire', 'admin') NOT NULL DEFAULT 'employe',
    `date_creation` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_utilisateurs_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Habitats présentés dans le zoo et informations d'entretien.
CREATE TABLE `habitats` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `nom` VARCHAR(150) NOT NULL,
    `description` TEXT NOT NULL,
    `superficie` DECIMAL(10,2) NOT NULL,
    `commentaire_entretien` TEXT,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Races ou variétés auxquelles les animaux sont rattachés.
CREATE TABLE `races` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `nom` VARCHAR(150) NOT NULL,
    `description` TEXT NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Animaux du zoo (table conservant le nom déjà utilisé par le projet).
CREATE TABLE `animaux` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `nom` VARCHAR(150) NOT NULL,
    `date_naissance` DATE NOT NULL,
    `sexe` ENUM('M', 'F') NOT NULL,
    `etat_sante` VARCHAR(255) NOT NULL,
    `id_habitat` INT NOT NULL,
    `id_race` INT NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY `idx_animaux_id_habitat` (`id_habitat`),
    KEY `idx_animaux_id_race` (`id_race`),
    CONSTRAINT `fk_animaux_habitat` FOREIGN KEY (`id_habitat`) REFERENCES `habitats` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_animaux_race` FOREIGN KEY (`id_race`) REFERENCES `races` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Rations distribuées aux animaux, horodatées.
CREATE TABLE `alimentations` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `id_animal` INT NOT NULL,
    `date_heure` DATETIME NOT NULL,
    `type_nourriture` VARCHAR(150) NOT NULL,
    `quantite` DECIMAL(10,2) NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY `idx_alimentations_id_animal` (`id_animal`),
    CONSTRAINT `fk_alimentations_animal` FOREIGN KEY (`id_animal`) REFERENCES `animaux` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Rapports de suivi rédigés par un vétérinaire (historique conservé si compte supprimé).
CREATE TABLE `rapports_veterinaires` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `id_animal` INT NOT NULL,
    `id_veterinaire` INT NULL,
    `date_rapport` DATE NOT NULL,
    `contenu` TEXT NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY `idx_rapports_id_animal` (`id_animal`),
    KEY `idx_rapports_id_veterinaire` (`id_veterinaire`),
    CONSTRAINT `fk_rapports_animal` FOREIGN KEY (`id_animal`) REFERENCES `animaux` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_rapports_veterinaire` FOREIGN KEY (`id_veterinaire`) REFERENCES `utilisateurs` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Services proposés aux visiteurs du zoo.
CREATE TABLE `services` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `nom` VARCHAR(150) NOT NULL,
    `description` TEXT NOT NULL,
    `horaires` VARCHAR(255) NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Images : au plus une cible parmi animal, habitat ou service (cible éventuellement absente).
-- La règle "une seule cible max" est appliquée par triggers (et non par CHECK,
-- incompatible avec des FK ON DELETE SET NULL sur les mêmes colonnes en MySQL 8).
CREATE TABLE `images` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `url` VARCHAR(500) NOT NULL,
    `id_animal` INT NULL,
    `id_habitat` INT NULL,
    `id_service` INT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY `idx_images_id_animal` (`id_animal`),
    KEY `idx_images_id_habitat` (`id_habitat`),
    KEY `idx_images_id_service` (`id_service`),
    CONSTRAINT `fk_images_animal` FOREIGN KEY (`id_animal`) REFERENCES `animaux` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_images_habitat` FOREIGN KEY (`id_habitat`) REFERENCES `habitats` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_images_service` FOREIGN KEY (`id_service`) REFERENCES `services` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DELIMITER $$

CREATE TRIGGER `trg_images_une_cible_insert` BEFORE INSERT ON `images`
FOR EACH ROW
BEGIN
    IF (
        (NEW.id_animal IS NOT NULL) +
        (NEW.id_habitat IS NOT NULL) +
        (NEW.id_service IS NOT NULL)
    ) > 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Une image ne peut cibler qu un seul element (animal, habitat ou service).';
    END IF;
END$$

CREATE TRIGGER `trg_images_une_cible_update` BEFORE UPDATE ON `images`
FOR EACH ROW
BEGIN
    IF (
        (NEW.id_animal IS NOT NULL) +
        (NEW.id_habitat IS NOT NULL) +
        (NEW.id_service IS NOT NULL)
    ) > 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Une image ne peut cibler qu un seul element (animal, habitat ou service).';
    END IF;
END$$

DELIMITER ;

-- Avis visiteurs, modérables par un utilisateur du back-office.
CREATE TABLE `avis` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `nom_visiteur` VARCHAR(150) NOT NULL,
    `contenu` TEXT NOT NULL,
    `note` INT NOT NULL,
    `is_visible` BOOLEAN NOT NULL DEFAULT FALSE,
    `date_creation` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `id_moderateur` INT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY `idx_avis_id_moderateur` (`id_moderateur`),
    CONSTRAINT `chk_avis_note` CHECK (`note` BETWEEN 1 AND 5),
    CONSTRAINT `fk_avis_moderateur` FOREIGN KEY (`id_moderateur`) REFERENCES `utilisateurs` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Messages envoyés via le formulaire de contact.
CREATE TABLE `contacts` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `nom` VARCHAR(150) NOT NULL,
    `email` VARCHAR(255) NOT NULL,
    `message` TEXT NOT NULL,
    `date_envoi` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Données de test cohérentes (dates fixes pour des réexécutions reproductibles)
-- ============================================================================

INSERT INTO `utilisateurs` (`nom`, `prenom`, `email`, `mot_de_passe`, `role`, `date_creation`) VALUES
('Martin', 'Claire', 'claire.martin@arcadia.test', '$2y$10$exemple-hachage-claire', 'veterinaire', '2026-01-10 09:00:00'),
('Bernard', 'Hugo', 'hugo.bernard@arcadia.test', '$2y$10$exemple-hachage-hugo', 'admin', '2026-01-11 10:30:00'),
('Leroy', 'Sophie', 'sophie.leroy@arcadia.test', '$2y$10$exemple-hachage-sophie', 'employe', '2026-01-12 08:15:00');

INSERT INTO `habitats` (`nom`, `description`, `superficie`, `commentaire_entretien`) VALUES
('Savane africaine', 'Plaine ouverte accueillant les girafes et les zèbres.', 2500.00, 'Vérifier les points d eau chaque matin.'),
('Forêt tropicale', 'Espace chaud et végétalisé pour les primates et les oiseaux.', 1800.50, 'Brumisation programmée à 08 h et 16 h.'),
('Rivière des loutres', 'Bassin avec berges rocheuses et zones de repos.', 650.00, 'Contrôler la qualité de l eau deux fois par jour.');

INSERT INTO `races` (`nom`, `description`) VALUES
('Girafe Masaï', 'Grande girafe d Afrique de l Est au pelage irrégulier.'),
('Lion d Afrique', 'Félin social vivant en groupe dans les savanes.'),
('Loutre d Europe', 'Petit mammifère semi-aquatique agile et joueur.');

INSERT INTO `animaux` (`nom`, `date_naissance`, `sexe`, `etat_sante`, `id_habitat`, `id_race`) VALUES
('Soleil', '2019-04-12', 'F', 'Bonne santé, suivi annuel à jour', 1, 1),
('Kito', '2017-09-03', 'M', 'Bonne santé', 1, 2),
('Naya', '2021-06-21', 'F', 'Sous surveillance dentaire', 2, 2),
('Plume', '2020-02-14', 'F', 'Bonne santé', 3, 3);

INSERT INTO `alimentations` (`id_animal`, `date_heure`, `type_nourriture`, `quantite`) VALUES
(1, '2026-08-18 08:00:00', 'Feuilles d acacia', 18.50),
(2, '2026-08-18 11:30:00', 'Viande de bœuf', 7.00),
(4, '2026-08-18 09:15:00', 'Poissons frais', 1.20);

INSERT INTO `rapports_veterinaires` (`id_animal`, `id_veterinaire`, `date_rapport`, `contenu`) VALUES
(1, 1, '2026-08-17', 'Examen général satisfaisant. Appétit et mobilité normaux.');

INSERT INTO `services` (`nom`, `description`, `horaires`) VALUES
('Visite guidée', 'Découverte des habitats avec un animateur animalier.', 'Tous les jours à 10 h 30 et 15 h 00');

INSERT INTO `images` (`url`, `id_animal`) VALUES
('https://cdn.arcadia.test/images/soleil-girafe.jpg', 1);

INSERT INTO `avis` (`nom_visiteur`, `contenu`, `note`, `is_visible`, `date_creation`, `id_moderateur`) VALUES
('Élodie Petit', 'Une visite magnifique, les soigneurs sont passionnés !', 5, TRUE, '2026-08-17 16:20:00', 2);

INSERT INTO `contacts` (`nom`, `email`, `message`, `date_envoi`) VALUES
('Thomas Durand', 'thomas.durand@example.com', 'Bonjour, proposez-vous des visites adaptées aux enfants ?', '2026-08-18 11:05:00');