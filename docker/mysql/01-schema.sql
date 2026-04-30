-- MySQL dump 10.13  Distrib 8.0.43, for Linux (aarch64)
--
-- Host: 127.0.0.1    Database: appliceo_php
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ap_accessibilite_accueil`
--

DROP TABLE IF EXISTS `ap_accessibilite_accueil`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_accessibilite_accueil` (
  `id_element_accessibilite` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `titre_fr` varchar(255) DEFAULT NULL,
  `texte_fr` longtext,
  `titre_en` varchar(255) DEFAULT NULL,
  `texte_en` longtext,
  `fichier` varchar(255) DEFAULT NULL,
  `nom_fichier` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `nom_image` varchar(255) DEFAULT NULL,
  `format_image` varchar(5) DEFAULT NULL,
  `largeur_image` int DEFAULT NULL,
  `hauteur_image` int DEFAULT NULL,
  `icone_alt_fr` varchar(255) DEFAULT NULL,
  `icone_alt_en` varchar(255) DEFAULT NULL,
  `image_alt_fr` varchar(255) DEFAULT NULL,
  `image_alt_en` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_element_accessibilite`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_accueil`
--

DROP TABLE IF EXISTS `ap_accueil`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_accueil` (
  `id_accueil` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `titre_temoignages_fr` varchar(255) DEFAULT NULL,
  `titre_temoignages_en` varchar(255) DEFAULT NULL,
  `titre_accessibilite_fr` varchar(255) DEFAULT NULL,
  `titre_accessibilite_en` varchar(255) DEFAULT NULL,
  `meta_description_fr` varchar(255) DEFAULT NULL,
  `meta_description_en` varchar(255) DEFAULT NULL,
  `titre_fonctionnalites_fr` varchar(255) DEFAULT NULL,
  `titre_fonctionnalites_en` varchar(255) DEFAULT NULL,
  `titre_fonctionnement_fr` varchar(255) DEFAULT NULL,
  `titre_fonctionnement_en` varchar(255) DEFAULT NULL,
  `titre_page_fr` varchar(61) DEFAULT NULL,
  `titre_page_en` varchar(61) DEFAULT NULL,
  PRIMARY KEY (`id_accueil`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_avis_echeance`
--

DROP TABLE IF EXISTS `ap_avis_echeance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_avis_echeance` (
  `id_avis_echeance` int NOT NULL AUTO_INCREMENT,
  `id_bail` int NOT NULL,
  `id_locataire` int NOT NULL,
  `id_entite` int NOT NULL,
  `id_utilisateur` int NOT NULL,
  `revision_pourcentage_taux` decimal(10,2) DEFAULT NULL,
  `revision_pourcentage_frequence` int DEFAULT NULL,
  `revision_pourcentage_loyer_base` varchar(7) DEFAULT NULL,
  `indice_base_mois` int DEFAULT NULL,
  `indice_base_trimestre` int DEFAULT NULL,
  `indice_base_annee` int DEFAULT NULL,
  `indice_base` decimal(6,2) DEFAULT NULL,
  `indice_revise_mois` int DEFAULT NULL,
  `indice_revise_trimestre` int DEFAULT NULL,
  `indice_revise_annee` int DEFAULT NULL,
  `indice_revise` decimal(6,2) DEFAULT NULL,
  `loyer_initial` decimal(12,2) DEFAULT NULL,
  `loyer_revise` decimal(12,2) DEFAULT NULL,
  `depot_initial` decimal(12,2) DEFAULT NULL,
  `depot_revise` decimal(12,2) DEFAULT NULL,
  `taxe` varchar(50) DEFAULT NULL,
  `taxe_taux` decimal(5,2) DEFAULT NULL,
  `taxe_autre` varchar(50) DEFAULT NULL,
  `taxe_autre_taux` decimal(5,2) DEFAULT NULL,
  `revision_indice` varchar(16) DEFAULT NULL,
  `aide_au_logement` decimal(12,2) DEFAULT NULL,
  `autre_poste_1` varchar(100) DEFAULT NULL,
  `autre_poste_montant_1` decimal(12,2) DEFAULT NULL,
  `autre_poste_taxe_1` int DEFAULT NULL,
  `autre_poste_proratisation_1` tinyint(1) DEFAULT NULL,
  `autre_poste_2` varchar(100) DEFAULT NULL,
  `autre_poste_montant_2` decimal(12,2) DEFAULT NULL,
  `autre_poste_taxe_2` int DEFAULT NULL,
  `autre_poste_proratisation_2` tinyint(1) DEFAULT NULL,
  `autre_poste_3` varchar(100) DEFAULT NULL,
  `autre_poste_montant_3` decimal(12,2) DEFAULT NULL,
  `autre_poste_taxe_3` int DEFAULT NULL,
  `autre_poste_proratisation_3` tinyint(1) DEFAULT NULL,
  `autre_poste_4` varchar(100) DEFAULT NULL,
  `autre_poste_montant_4` decimal(12,2) DEFAULT NULL,
  `autre_poste_taxe_4` int DEFAULT NULL,
  `autre_poste_proratisation_4` tinyint(1) DEFAULT NULL,
  `autre_poste_5` varchar(100) DEFAULT NULL,
  `autre_poste_montant_5` decimal(12,2) DEFAULT NULL,
  `autre_poste_taxe_5` int DEFAULT NULL,
  `autre_poste_proratisation_5` tinyint(1) DEFAULT NULL,
  `charge_provision_proratisation` tinyint(1) DEFAULT '1',
  `montant_total` decimal(12,2) DEFAULT NULL,
  `devise` varchar(5) DEFAULT NULL,
  `date_debut_bail` timestamp NULL DEFAULT NULL,
  `periode_debut` date DEFAULT NULL,
  `periode_fin` date DEFAULT NULL,
  `envoye` varchar(1) DEFAULT NULL,
  `paye` tinyint(1) NOT NULL DEFAULT '0',
  `ignorer` tinyint(1) NOT NULL,
  `fichier_avis_echeance` varchar(255) NOT NULL,
  `fichier_quittance_loyer` varchar(255) DEFAULT NULL,
  `date_planifiee` timestamp NULL DEFAULT NULL,
  `date_creation` timestamp NULL DEFAULT NULL,
  `poids_avis_echeance` int DEFAULT NULL,
  `date_rappel_1` timestamp NULL DEFAULT NULL,
  `date_rappel_2` timestamp NULL DEFAULT NULL,
  `date_creation_quittance` timestamp NULL DEFAULT NULL,
  `poids_quittance_loyer` int DEFAULT NULL,
  `quittance_envoyee` varchar(1) DEFAULT NULL,
  `methode_envoi_quittance` varchar(1) DEFAULT NULL,
  `hash` varchar(32) NOT NULL,
  `date_paiement_complet` date DEFAULT NULL,
  `date_paiement_partiel_1` date DEFAULT NULL,
  `date_paiement_partiel_2` date DEFAULT NULL,
  `date_paiement_partiel_3` date DEFAULT NULL,
  `date_paiement_partiel_4` date DEFAULT NULL,
  `date_paiement_partiel_5` date DEFAULT NULL,
  `date_paiement_partiel_6` date DEFAULT NULL,
  `date_paiement_partiel_7` date DEFAULT NULL,
  `date_paiement_partiel_8` date DEFAULT NULL,
  `date_paiement_partiel_9` date DEFAULT NULL,
  `date_paiement_partiel_10` date DEFAULT NULL,
  `montant_paiement_partiel_1` decimal(10,2) DEFAULT NULL,
  `montant_paiement_partiel_2` decimal(10,2) DEFAULT NULL,
  `montant_paiement_partiel_3` decimal(10,2) DEFAULT NULL,
  `montant_paiement_partiel_4` decimal(10,2) DEFAULT NULL,
  `montant_paiement_partiel_5` decimal(10,2) DEFAULT NULL,
  `montant_paiement_partiel_6` decimal(10,2) DEFAULT NULL,
  `montant_paiement_partiel_7` decimal(10,2) DEFAULT NULL,
  `montant_paiement_partiel_8` decimal(10,2) DEFAULT NULL,
  `montant_paiement_partiel_9` decimal(10,2) DEFAULT NULL,
  `montant_paiement_partiel_10` decimal(10,2) DEFAULT NULL,
  `description_paiement_partiel_1` varchar(75) DEFAULT NULL,
  `description_paiement_partiel_2` varchar(75) DEFAULT NULL,
  `description_paiement_partiel_3` varchar(75) DEFAULT NULL,
  `description_paiement_partiel_4` varchar(75) DEFAULT NULL,
  `description_paiement_partiel_5` varchar(75) DEFAULT NULL,
  `description_paiement_partiel_6` varchar(75) DEFAULT NULL,
  `description_paiement_partiel_7` varchar(75) DEFAULT NULL,
  `description_paiement_partiel_8` varchar(75) DEFAULT NULL,
  `description_paiement_partiel_9` varchar(75) DEFAULT NULL,
  `description_paiement_partiel_10` varchar(75) DEFAULT NULL,
  `total_paiements_partiels` decimal(10,2) DEFAULT NULL,
  `total_paiements_partiels_periode` decimal(10,2) DEFAULT NULL,
  `date_depense_1` date DEFAULT NULL,
  `nature_depense_1` varchar(255) DEFAULT NULL,
  `montant_depense_1` decimal(10,2) DEFAULT NULL,
  `type_depense_1` int DEFAULT NULL,
  `date_depense_2` date DEFAULT NULL,
  `nature_depense_2` varchar(255) DEFAULT NULL,
  `montant_depense_2` decimal(10,2) DEFAULT NULL,
  `type_depense_2` int DEFAULT NULL,
  `date_depense_3` date DEFAULT NULL,
  `nature_depense_3` varchar(255) DEFAULT NULL,
  `montant_depense_3` decimal(10,2) DEFAULT NULL,
  `type_depense_3` int DEFAULT NULL,
  `date_depense_4` date DEFAULT NULL,
  `nature_depense_4` varchar(255) DEFAULT NULL,
  `montant_depense_4` decimal(10,2) DEFAULT NULL,
  `type_depense_4` int DEFAULT NULL,
  `date_depense_5` date DEFAULT NULL,
  `nature_depense_5` varchar(255) DEFAULT NULL,
  `montant_depense_5` decimal(10,2) DEFAULT NULL,
  `type_depense_5` int DEFAULT NULL,
  `total_depenses` decimal(10,2) DEFAULT NULL,
  `frais_agence` decimal(7,2) DEFAULT NULL,
  `frais_agence_type_loyer` tinyint(1) DEFAULT NULL,
  `frais_agence_depot` tinyint(1) DEFAULT NULL,
  `montant_frais_agence` decimal(13,2) DEFAULT NULL,
  `frais_agence_taxe` decimal(5,2) DEFAULT NULL,
  `montant_frais_agence_taxe` decimal(13,2) DEFAULT NULL,
  `frais_assurance_impayes` decimal(5,2) DEFAULT NULL,
  `frais_assurance_impayes_type_loyer` tinyint(1) DEFAULT NULL,
  `montant_frais_assurance_impayes` decimal(13,2) DEFAULT NULL,
  `montant_frais_intervention` decimal(13,2) DEFAULT NULL,
  `acompte_proprietaire` decimal(5,2) DEFAULT NULL,
  `date_creation_compte_rendu` timestamp NULL DEFAULT NULL,
  `fichier_compte_rendu` varchar(255) DEFAULT NULL,
  `poids_compte_rendu` int DEFAULT NULL,
  `date_envoi_compte_rendu` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_avis_echeance`),
  KEY `id_locataire` (`id_locataire`),
  KEY `id_bail` (`id_bail`)
) ENGINE=InnoDB AUTO_INCREMENT=245042 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_avis_echeance_postes`
--

DROP TABLE IF EXISTS `ap_avis_echeance_postes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_avis_echeance_postes` (
  `id_poste` int NOT NULL AUTO_INCREMENT,
  `id_avis_echeance` int NOT NULL,
  `id_bail` int NOT NULL,
  `id_locataire` int NOT NULL,
  `id_entite` int NOT NULL,
  `id_utilisateur` int NOT NULL,
  `proprietaire_SAVE` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `proprietaire` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `locataire` varchar(255) NOT NULL,
  `adresse_locataire` varchar(255) NOT NULL,
  `date_creation` timestamp NOT NULL,
  `periode_debut` date NOT NULL,
  `periode_fin` date NOT NULL,
  `date_exigibilite` date NOT NULL,
  `reference` varchar(255) NOT NULL,
  `poste` varchar(255) NOT NULL,
  `type` varchar(25) NOT NULL,
  `montant` decimal(12,2) NOT NULL,
  `montant_avis_echeance` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id_poste`),
  KEY `id_avis_echeance` (`id_avis_echeance`)
) ENGINE=InnoDB AUTO_INCREMENT=1074645 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_bail_guarantor`
--

DROP TABLE IF EXISTS `ap_bail_guarantor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_bail_guarantor` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_bail` int NOT NULL,
  `guarantor_id` int unsigned NOT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `position` tinyint unsigned NOT NULL DEFAULT '1',
  `id_amendment` int unsigned DEFAULT NULL,
  `notes` text,
  `date_creation` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_bail` (`id_bail`),
  KEY `idx_guarantor` (`guarantor_id`),
  KEY `idx_bail_status` (`id_bail`,`status`),
  KEY `idx_amendment` (`id_amendment`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_bandeau_accueil`
--

DROP TABLE IF EXISTS `ap_bandeau_accueil`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_bandeau_accueil` (
  `id_bandeau_accueil` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `texte_fr` longtext,
  `fichier` varchar(255) DEFAULT NULL,
  `nom_fichier` varchar(255) DEFAULT NULL,
  `texte_en` longtext,
  `image_alt_fr` varchar(255) DEFAULT NULL,
  `image_alt_en` varchar(255) DEFAULT NULL,
  `punchline_fr` longtext,
  `punchline_en` longtext,
  PRIMARY KEY (`id_bandeau_accueil`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_baux`
--

DROP TABLE IF EXISTS `ap_baux`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_baux` (
  `id_bail` int NOT NULL AUTO_INCREMENT,
  `id_locataire` int NOT NULL,
  `id_utilisateur` int NOT NULL,
  `id_entite` int NOT NULL,
  `id_lot_1` int DEFAULT NULL,
  `id_lot_2` int DEFAULT NULL,
  `id_lot_3` int DEFAULT NULL,
  `id_lot_4` int DEFAULT NULL,
  `titulaires` longtext,
  `notes` longtext,
  `langue` varchar(2) NOT NULL,
  `duree_bail` int DEFAULT NULL,
  `duree_bail_unite` varchar(1) NOT NULL,
  `date_debut_bail` timestamp NULL DEFAULT NULL,
  `date_fin_bail` timestamp NULL DEFAULT NULL,
  `type_bail` varchar(2) NOT NULL,
  `devise` varchar(5) NOT NULL,
  `jour_exigibilite` int DEFAULT NULL,
  `date_entree` timestamp NULL DEFAULT NULL,
  `date_sortie` timestamp NULL DEFAULT NULL,
  `loyer_initial` decimal(12,2) DEFAULT NULL,
  `depot_initial` decimal(12,2) DEFAULT NULL,
  `caution` varchar(11) NOT NULL,
  `caution_montant` decimal(12,2) DEFAULT NULL,
  `taxe` varchar(50) DEFAULT NULL,
  `taxe_taux` decimal(5,2) DEFAULT NULL,
  `taxe_autre` varchar(50) DEFAULT NULL,
  `taxe_autre_taux` decimal(5,2) DEFAULT NULL,
  `mode` varchar(4) DEFAULT NULL,
  `reglement` int DEFAULT NULL,
  `date_memo_1` date DEFAULT NULL,
  `date_memo_2` date DEFAULT NULL,
  `date_memo_3` date DEFAULT NULL,
  `frequence_memo_1` int DEFAULT NULL,
  `frequence_memo_2` int DEFAULT NULL,
  `frequence_memo_3` int DEFAULT NULL,
  `destinataire_memo_1` varchar(1) DEFAULT NULL,
  `destinataire_memo_2` varchar(1) DEFAULT NULL,
  `destinataire_memo_3` varchar(1) DEFAULT NULL,
  `date_envoi_memo_1` date DEFAULT NULL,
  `date_envoi_memo_2` date DEFAULT NULL,
  `date_envoi_memo_3` date DEFAULT NULL,
  `texte_memo_1` longtext,
  `texte_memo_2` longtext,
  `texte_memo_3` longtext,
  `revision_type` varchar(11) NOT NULL,
  `revision_pourcentage_taux` decimal(10,2) DEFAULT NULL,
  `revision_pourcentage_frequence` int DEFAULT NULL,
  `revision_pourcentage_loyer_base` varchar(7) DEFAULT NULL,
  `revision_frequence` int DEFAULT NULL,
  `date_derniere_revision_prevue` date DEFAULT NULL,
  `date_alerte_derniere_revision_prevue` timestamp NULL DEFAULT NULL,
  `jours_alerte_revision_loyer` int NOT NULL,
  `alerte_revision_loyer_message` longtext NOT NULL,
  `indice_base_mois` int DEFAULT NULL,
  `indice_base_trimestre` int DEFAULT NULL,
  `indice_base_annee` int DEFAULT NULL,
  `indice_base` decimal(10,2) DEFAULT NULL,
  `indice_revise` decimal(10,2) DEFAULT NULL,
  `indice_revise_attendu_date` timestamp NULL DEFAULT NULL,
  `indice_revise_attendu_date_disponible` timestamp NULL DEFAULT NULL,
  `indice_revise_mois_attendu` int DEFAULT NULL,
  `indice_revise_trimestre_attendu` int DEFAULT NULL,
  `indice_revise_annee_attendu` int DEFAULT NULL,
  `revision_hausse_uniquement` tinyint(1) NOT NULL DEFAULT '0',
  `revision_indice` varchar(16) DEFAULT NULL,
  `revision_depot` int NOT NULL,
  `aide_au_logement` decimal(12,2) DEFAULT NULL,
  `autre_poste_1` varchar(100) DEFAULT NULL,
  `autre_poste_montant_1` decimal(12,2) DEFAULT NULL,
  `autre_poste_taxe_1` int DEFAULT NULL,
  `autre_poste_proratisation_1` tinyint(1) DEFAULT NULL,
  `autre_poste_2` varchar(100) DEFAULT NULL,
  `autre_poste_montant_2` decimal(12,2) DEFAULT NULL,
  `autre_poste_taxe_2` int DEFAULT NULL,
  `autre_poste_proratisation_2` tinyint(1) DEFAULT NULL,
  `autre_poste_3` varchar(100) DEFAULT NULL,
  `autre_poste_montant_3` decimal(12,2) DEFAULT NULL,
  `autre_poste_taxe_3` int DEFAULT NULL,
  `autre_poste_proratisation_3` tinyint(1) DEFAULT NULL,
  `autre_poste_4` varchar(100) DEFAULT NULL,
  `autre_poste_montant_4` decimal(12,2) DEFAULT NULL,
  `autre_poste_taxe_4` int DEFAULT NULL,
  `autre_poste_proratisation_4` tinyint(1) DEFAULT NULL,
  `autre_poste_5` varchar(100) DEFAULT NULL,
  `autre_poste_montant_5` decimal(12,2) DEFAULT NULL,
  `autre_poste_taxe_5` int DEFAULT NULL,
  `autre_poste_proratisation_5` tinyint(1) DEFAULT NULL,
  `conserver_depot` tinyint(1) DEFAULT NULL,
  `frais_agence` decimal(7,2) DEFAULT NULL,
  `frais_agence_type_loyer` tinyint(1) DEFAULT NULL,
  `frais_agence_depot` tinyint(1) DEFAULT NULL,
  `frais_agence_taxe` decimal(5,2) DEFAULT NULL,
  `frais_assurance_impayes` decimal(5,2) DEFAULT NULL,
  `frais_assurance_impayes_type_loyer` tinyint(1) DEFAULT NULL,
  `acompte_proprietaire` decimal(5,2) DEFAULT NULL,
  `acompte_proprietaire_type` tinyint(1) DEFAULT NULL,
  `civilite_proprietaire` varchar(2) DEFAULT NULL,
  `prenom_proprietaire` varchar(75) DEFAULT NULL,
  `nom_proprietaire` varchar(75) DEFAULT NULL,
  `email_proprietaire` varchar(75) DEFAULT NULL,
  `telephone_proprietaire` varchar(15) DEFAULT NULL,
  `mobile_proprietaire` varchar(15) DEFAULT NULL,
  `adresse_proprietaire` varchar(255) DEFAULT NULL,
  `code_postal_proprietaire` varchar(10) DEFAULT NULL,
  `ville_proprietaire` varchar(75) DEFAULT NULL,
  `pays_proprietaire` int DEFAULT NULL,
  `langue_proprietaire` varchar(2) DEFAULT NULL,
  `forme_juridique_proprietaire` varchar(10) DEFAULT NULL,
  `mois_envoi` int NOT NULL DEFAULT '0',
  `jour_envoi` int NOT NULL,
  `heure_envoi` int DEFAULT NULL,
  `jours_premier_rappel` int NOT NULL,
  `jours_second_rappel` int NOT NULL,
  `envoi_message` longtext NOT NULL,
  `premier_rappel_message` longtext NOT NULL,
  `second_rappel_message` longtext NOT NULL,
  `quittance_message` longtext NOT NULL,
  `recu_message` longtext NOT NULL,
  `email_copie_utilisateur` tinyint(1) NOT NULL,
  `email_copie_comptable` tinyint(1) NOT NULL,
  `email_copie` longtext NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `automatisation` tinyint(1) NOT NULL,
  `date_automatisation` timestamp NULL DEFAULT NULL,
  `charge_provision` tinyint(1) DEFAULT '0' COMMENT 'Charge provision checkbox (1=yes, 0=no)',
  `charge_provision_amount` decimal(10,2) DEFAULT NULL COMMENT 'Charge provision amount',
  `charge_provision_tax` varchar(50) DEFAULT NULL COMMENT 'Tax included in charge provision',
  `charge_provision_proratisation` tinyint(1) DEFAULT '1',
  `is_signed` tinyint(1) DEFAULT '0' COMMENT 'Boolean flag for electronic signature',
  `guarantor` varchar(255) DEFAULT NULL,
  `guarantor_address` varchar(255) DEFAULT NULL,
  `guarantor_email` varchar(75) DEFAULT NULL,
  `guarantor_2` varchar(255) DEFAULT NULL,
  `guarantor_address_2` varchar(255) DEFAULT NULL,
  `guarantor_email_2` varchar(75) DEFAULT NULL,
  `guarantor_id` int unsigned DEFAULT NULL,
  `guarantor_2_id` int unsigned DEFAULT NULL,
  `guarantee_name` varchar(255) DEFAULT NULL,
  `guarantee_firstname` varchar(100) DEFAULT NULL,
  `guarantee_address` varchar(255) DEFAULT NULL,
  `guarantee_email` varchar(75) DEFAULT NULL,
  `guarantee_phone` varchar(20) DEFAULT NULL,
  `guarantee_birthdate` date DEFAULT NULL,
  `guarantee_profession` varchar(100) DEFAULT NULL,
  `guarantee_reference` varchar(100) DEFAULT NULL,
  `other_conditions` text,
  `annexes` varchar(255) DEFAULT NULL,
  `signing_date` date DEFAULT NULL,
  `signing_place` varchar(255) DEFAULT NULL,
  `unit_desc` text,
  `rental_fees` tinyint(1) DEFAULT '0' COMMENT 'Boolean flag for rental fees',
  `fee_ceiling_visit` decimal(10,2) DEFAULT NULL COMMENT 'Fee ceiling for visit, dossier and lease drafting',
  `fee_ceiling_entry` decimal(10,2) DEFAULT NULL COMMENT 'Fee ceiling for entry condition report',
  `lender_fees_lease` text COMMENT 'Lender fees for visit, dossier and lease drafting',
  `lender_fees_visit` text COMMENT 'Lender fees for entry condition report',
  `lender_fees_other` text COMMENT 'Other lender fees',
  `renter_fees_lease` text COMMENT 'Renter fees for visit, dossier and lease drafting',
  `renter_fees_visit` text COMMENT 'Renter fees for entry condition report',
  `evolution_decree` tinyint(1) DEFAULT '0' COMMENT 'Boolean flag for evolution decree',
  `evolution_decree_prefectoral` tinyint(1) DEFAULT '0' COMMENT 'Boolean flag for prefectoral decree',
  `prefectoral_ref_rent` decimal(10,2) DEFAULT NULL COMMENT 'Prefectoral reference rent amount',
  `prefectoral_increased_ref_rent` decimal(10,2) DEFAULT NULL COMMENT 'Prefectoral increased reference rent amount',
  `rent_supplement` tinyint(1) DEFAULT '0' COMMENT 'Boolean flag for rent supplement',
  `rent_supplement_base` decimal(10,2) DEFAULT NULL COMMENT 'Base rent amount for rent supplement',
  `rent_supplement_amount` decimal(10,2) DEFAULT NULL COMMENT 'Rent supplement amount',
  `rent_supplement_characteristics` text COMMENT 'Characteristics justifying rent supplement',
  `previous_tenant_infos` tinyint(1) DEFAULT '0' COMMENT 'Boolean flag for previous tenant information',
  `previous_tenant_rent` decimal(10,2) DEFAULT NULL COMMENT 'Previous tenant rent amount',
  `previous_tenant_last_date` date DEFAULT NULL COMMENT 'Previous tenant last payment date',
  `previous_tenant_last_revision` date DEFAULT NULL COMMENT 'Previous tenant last rent revision date',
  `renter_assurance` tinyint(1) DEFAULT '0' COMMENT 'Boolean flag for renter assurance',
  `renter_assurance_amount` decimal(10,2) DEFAULT NULL COMMENT 'Renter assurance annual amount',
  `renew_reassessing` tinyint(1) DEFAULT '0' COMMENT 'Boolean flag for renew reassessing',
  `renew_reassessing_amount` decimal(10,2) DEFAULT NULL COMMENT 'Renew reassessing monthly rent increase amount',
  `renew_reassessing_split` varchar(1) DEFAULT NULL COMMENT 'Renew reassessing split type (t=by third, s=by sixth)',
  `work_since_last_lease` text COMMENT 'Amount and nature of improvement or compliance work done since last lease',
  `work_since_last_6m` decimal(10,2) DEFAULT NULL COMMENT 'Amount of improvement work done in the last 6 months',
  `renter_work_raise_cause` text COMMENT 'Nature of work causing rent increase',
  `renter_work_raise_amount` decimal(10,2) DEFAULT NULL COMMENT 'Amount of rent increase due to work',
  `tenant_work_decrease_cause` text COMMENT 'Nature of work causing rent decrease',
  `tenant_work_decrease_amount` decimal(10,2) DEFAULT NULL COMMENT 'Amount of rent decrease due to tenant work',
  `tenant_work_decrease_duration` int DEFAULT NULL COMMENT 'Duration of rent decrease in months',
  `occupation` tinyint(1) DEFAULT '0' COMMENT 'Is unit currently occupied? If TRUE, previous tenant fields are mandatory',
  `previous_tenant_name` varchar(255) DEFAULT NULL COMMENT 'Name of previous tenant (mandatory if occupation=TRUE)',
  `previous_tenant_leave_date` date DEFAULT NULL COMMENT 'Date previous tenant gave notice (mandatory if occupation=TRUE)',
  `property_tax` decimal(10,2) DEFAULT NULL COMMENT 'Property tax provision amount',
  `office_tax` decimal(10,2) DEFAULT NULL COMMENT 'Office/commercial tax provision (IDF)',
  `bank_guarantee_due_date` date DEFAULT NULL COMMENT 'Bank guarantee production deadline (for caution=bancaire)',
  `franchise` int DEFAULT NULL,
  `sous_locataires` tinyint(1) DEFAULT '0',
  `property_tax_quarterly` decimal(10,2) DEFAULT NULL COMMENT 'Quarterly property tax provision',
  `office_tax_quarterly` decimal(10,2) DEFAULT NULL COMMENT 'Quarterly office/commercial tax (ÃŽle-de-France)',
  `mobility_reason` varchar(255) DEFAULT NULL,
  `arrival_time` varchar(5) DEFAULT NULL,
  `departure_time` varchar(5) DEFAULT NULL,
  `advance_amount` decimal(12,2) DEFAULT NULL,
  `advance_type` varchar(10) DEFAULT NULL,
  `property_tax_tenant` tinyint(1) NOT NULL DEFAULT '0',
  `validated_at` datetime DEFAULT NULL,
  `property_tax_proratisation` tinyint(1) DEFAULT '1',
  `property_tax_tax` tinyint(1) DEFAULT '0',
  `tenant_commercial_activity` text,
  PRIMARY KEY (`id_bail`),
  KEY `id_locataire` (`id_locataire`),
  KEY `id_lot_1` (`id_lot_1`),
  KEY `id_lot_2` (`id_lot_2`),
  KEY `id_lot_3` (`id_lot_3`),
  KEY `id_lot_4` (`id_lot_4`),
  KEY `date_sortie` (`date_sortie`),
  KEY `email_proprietaire` (`email_proprietaire`),
  KEY `idx_guarantor_id` (`guarantor_id`),
  KEY `idx_guarantor_2_id` (`guarantor_2_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20520 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_categorie_modeles`
--

DROP TABLE IF EXISTS `ap_categorie_modeles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_categorie_modeles` (
  `id_categorie_de_modele` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  PRIMARY KEY (`id_categorie_de_modele`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_cgu`
--

DROP TABLE IF EXISTS `ap_cgu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_cgu` (
  `id_conditions_generales_dutilisation` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `texte_fr` longtext,
  `texte_en` longtext,
  `titre_page_fr` varchar(255) DEFAULT NULL,
  `titre_page_en` varchar(255) DEFAULT NULL,
  `meta_description_fr` varchar(255) DEFAULT NULL,
  `meta_description_en` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_conditions_generales_dutilisation`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_comptables`
--

DROP TABLE IF EXISTS `ap_comptables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_comptables` (
  `id_comptable` int NOT NULL AUTO_INCREMENT,
  `id_utilisateur` int NOT NULL,
  `ids_entites` longtext NOT NULL,
  `societe` varchar(255) NOT NULL,
  `civilite` varchar(2) NOT NULL,
  `nom` varchar(75) NOT NULL,
  `prenom` varchar(75) NOT NULL,
  `email` varchar(75) NOT NULL,
  `date_actualisation_email_utilisateur` timestamp NULL DEFAULT NULL,
  `utilisateur` varchar(255) NOT NULL,
  `mot_de_passe` varchar(9) NOT NULL,
  `telephone` varchar(15) NOT NULL,
  `mobile` varchar(15) NOT NULL,
  `adresse` varchar(255) NOT NULL,
  `code_postal` varchar(5) NOT NULL,
  `ville` varchar(75) NOT NULL,
  `pays` int NOT NULL,
  `notes` longtext,
  `langue` varchar(2) NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id_comptable`),
  KEY `id_utilisateur` (`id_utilisateur`),
  KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=298 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_contact`
--

DROP TABLE IF EXISTS `ap_contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_contact` (
  `id_contact` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `meta_description_fr` varchar(255) DEFAULT NULL,
  `meta_description_en` varchar(255) DEFAULT NULL,
  `adresse_postale` varchar(255) DEFAULT NULL,
  `code_postal` int DEFAULT NULL,
  `ville` varchar(100) DEFAULT NULL,
  `pays` varchar(100) DEFAULT NULL,
  `adresse_trouvee` varchar(255) DEFAULT NULL,
  `latitude` varchar(20) DEFAULT NULL,
  `longitude` varchar(20) DEFAULT NULL,
  `telephone_fr` varchar(255) DEFAULT NULL,
  `telephone_en` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `facebook_page` varchar(255) DEFAULT NULL,
  `twitter_page` varchar(255) DEFAULT NULL,
  `linkedin_page` varchar(255) DEFAULT NULL,
  `cle_api_google` varchar(255) DEFAULT NULL,
  `instagram_page` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_contact`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_creation_compte`
--

DROP TABLE IF EXISTS `ap_creation_compte`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_creation_compte` (
  `id_creation_compte` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `fichier` varchar(255) DEFAULT NULL,
  `nom_fichier` varchar(255) DEFAULT NULL,
  `titre_fr` varchar(255) DEFAULT NULL,
  `texte_fr` longtext,
  `titre_en` varchar(255) DEFAULT NULL,
  `texte_en` longtext,
  `image_alt_fr` varchar(255) DEFAULT NULL,
  `image_alt_en` varchar(255) DEFAULT NULL,
  `titre_encart_fr` varchar(255) DEFAULT NULL,
  `titre_encart_en` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_creation_compte`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_description_accueil`
--

DROP TABLE IF EXISTS `ap_description_accueil`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_description_accueil` (
  `id_description_accueil` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `fichier` varchar(255) DEFAULT NULL,
  `nom_fichier` varchar(255) DEFAULT NULL,
  `image_alt_fr` varchar(255) DEFAULT NULL,
  `image_alt_en` varchar(255) DEFAULT NULL,
  `titre_1_fr` varchar(255) DEFAULT NULL,
  `texte_1_fr` longtext,
  `titre_1_en` varchar(255) DEFAULT NULL,
  `texte_1_en` longtext,
  `titre_2_fr` varchar(255) DEFAULT NULL,
  `texte_2_fr` longtext,
  `titre_2_en` varchar(255) DEFAULT NULL,
  `texte_2_en` longtext,
  PRIMARY KEY (`id_description_accueil`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_destinataires_objets_contact`
--

DROP TABLE IF EXISTS `ap_destinataires_objets_contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_destinataires_objets_contact` (
  `id_destinataire` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  PRIMARY KEY (`id_destinataire`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_email_bounces`
--

DROP TABLE IF EXISTS `ap_email_bounces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_email_bounces` (
  `email` varchar(255) NOT NULL,
  `message` longtext NOT NULL,
  `date_envoi` timestamp NOT NULL,
  PRIMARY KEY (`email`),
  KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_emetteurs_objets_contact`
--

DROP TABLE IF EXISTS `ap_emetteurs_objets_contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_emetteurs_objets_contact` (
  `id_emetteur` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  PRIMARY KEY (`id_emetteur`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_entites`
--

DROP TABLE IF EXISTS `ap_entites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_entites` (
  `id_entite` int NOT NULL AUTO_INCREMENT,
  `id_utilisateur` int NOT NULL,
  `nom` varchar(75) NOT NULL,
  `type` varchar(1) NOT NULL,
  `adresse` varchar(255) NOT NULL,
  `code_postal` varchar(10) NOT NULL,
  `ville` varchar(75) NOT NULL,
  `pays` int NOT NULL,
  `telephone` varchar(15) NOT NULL,
  `fax` varchar(15) NOT NULL,
  `email` varchar(75) NOT NULL,
  `tva` varchar(25) DEFAULT NULL,
  `iban` varchar(34) DEFAULT NULL,
  `siren` varchar(25) DEFAULT NULL,
  `capital` decimal(12,2) DEFAULT NULL,
  `devise` varchar(5) DEFAULT NULL,
  `forme_juridique` varchar(10) DEFAULT NULL,
  `champ_libre` longtext,
  `logo` varchar(8) DEFAULT NULL,
  `poids_logo` int DEFAULT NULL,
  `signature` varchar(13) DEFAULT NULL,
  `poids_signature` int DEFAULT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id_entite`)
) ENGINE=InnoDB AUTO_INCREMENT=8544 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_entrees_menu`
--

DROP TABLE IF EXISTS `ap_entrees_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_entrees_menu` (
  `id_menu` int NOT NULL AUTO_INCREMENT,
  `nom_menu` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `id_table` int DEFAULT NULL,
  `id_menu_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  PRIMARY KEY (`id_menu`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_etapes_accueil`
--

DROP TABLE IF EXISTS `ap_etapes_accueil`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_etapes_accueil` (
  `id_etape` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `titre_fr` varchar(255) DEFAULT NULL,
  `texte_fr` longtext,
  `titre_en` varchar(255) DEFAULT NULL,
  `texte_en` longtext,
  `fichier` varchar(255) DEFAULT NULL,
  `nom_fichier` varchar(255) DEFAULT NULL,
  `image_alt_fr` varchar(255) DEFAULT NULL,
  `image_alt_en` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_etape`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_fichiers`
--

DROP TABLE IF EXISTS `ap_fichiers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_fichiers` (
  `id_fichier` int NOT NULL AUTO_INCREMENT,
  `id_bail` int NOT NULL,
  `id_entite` int NOT NULL,
  `id_utilisateur` int NOT NULL,
  `nom_fichier` varchar(75) NOT NULL,
  `fichier` varchar(255) DEFAULT NULL,
  `type_fichier` varchar(25) NOT NULL,
  `poids_fichier` int DEFAULT NULL,
  `date_creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_fichier`),
  KEY `id_bail` (`id_bail`)
) ENGINE=InnoDB AUTO_INCREMENT=5007 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_fonctionnalites_accueil`
--

DROP TABLE IF EXISTS `ap_fonctionnalites_accueil`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_fonctionnalites_accueil` (
  `id_fonctionnalite` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `titre_fr` varchar(255) DEFAULT NULL,
  `texte_fr` longtext,
  `titre_en` varchar(255) DEFAULT NULL,
  `texte_en` longtext,
  `fichier` varchar(255) DEFAULT NULL,
  `nom_fichier` varchar(255) DEFAULT NULL,
  `image_alt_fr` varchar(255) DEFAULT NULL,
  `image_alt_en` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_fonctionnalite`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_formules`
--

DROP TABLE IF EXISTS `ap_formules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_formules` (
  `id_formule` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `id_option` int DEFAULT NULL,
  `description_fr` longtext,
  `prix_mensuel` varchar(255) DEFAULT NULL,
  `nom_fr` varchar(255) DEFAULT NULL,
  `nom_en` varchar(255) DEFAULT NULL,
  `description_en` longtext,
  `fichier` varchar(255) DEFAULT NULL,
  `nom_fichier` varchar(255) DEFAULT NULL,
  `stripe_price_id_mensuel` varchar(255) DEFAULT NULL,
  `prix_annuel` varchar(255) DEFAULT NULL,
  `stripe_price_id_annuel` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_formule`)
) ENGINE=InnoDB AUTO_INCREMENT=100000 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_gratuite_accueil`
--

DROP TABLE IF EXISTS `ap_gratuite_accueil`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_gratuite_accueil` (
  `id_gratuite_accueil` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `texte_fr` longtext,
  `fichier` varchar(255) DEFAULT NULL,
  `nom_fichier` varchar(255) DEFAULT NULL,
  `titre_fr` varchar(255) DEFAULT NULL,
  `titre_en` varchar(255) DEFAULT NULL,
  `texte_en` longtext,
  `image_alt_fr` varchar(255) DEFAULT NULL,
  `image_alt_en` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_gratuite_accueil`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_guarantor`
--

DROP TABLE IF EXISTS `ap_guarantor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_guarantor` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `civilite` varchar(2) DEFAULT NULL,
  `last_name` varchar(255) NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `birth_date` date DEFAULT NULL,
  `birth_place` varchar(255) DEFAULT NULL,
  `birth_country` varchar(5) DEFAULT NULL,
  `email` varchar(75) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `postal_code` varchar(10) NOT NULL,
  `country` varchar(5) NOT NULL DEFAULT 'FR',
  `profession` varchar(255) DEFAULT NULL,
  `date_creation` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `id_utilisateur` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_indices`
--

DROP TABLE IF EXISTS `ap_indices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_indices` (
  `id_indice` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `trimestre` int DEFAULT NULL,
  `annee` varchar(255) DEFAULT NULL,
  `irl` decimal(8,2) DEFAULT NULL,
  `irl_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `icc` decimal(8,2) DEFAULT NULL,
  `icc_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ilc` decimal(8,2) DEFAULT NULL,
  `ilc_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ilat` decimal(8,2) DEFAULT NULL,
  `ilat_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `irl_om` varchar(255) DEFAULT NULL,
  `irl_om_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id_indice`)
) ENGINE=InnoDB AUTO_INCREMENT=290 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_indices_sante_belgique`
--

DROP TABLE IF EXISTS `ap_indices_sante_belgique`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_indices_sante_belgique` (
  `id_indice_sante` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `annee` varchar(4) DEFAULT NULL,
  `mois` int DEFAULT NULL,
  `sante_base_1996` decimal(6,2) DEFAULT NULL,
  `sante_base_2004` decimal(6,2) DEFAULT NULL,
  `sante_base_2013` decimal(6,2) DEFAULT NULL,
  `lisse_base_1996` decimal(6,2) DEFAULT NULL,
  `lisse_base_2004` decimal(6,2) DEFAULT NULL,
  `lisse_base_2013` decimal(6,2) DEFAULT NULL,
  PRIMARY KEY (`id_indice_sante`)
) ENGINE=InnoDB AUTO_INCREMENT=357 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_locataires`
--

DROP TABLE IF EXISTS `ap_locataires`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_locataires` (
  `id_locataire` int NOT NULL AUTO_INCREMENT,
  `id_utilisateur` int NOT NULL,
  `societe` varchar(255) NOT NULL,
  `civilite` varchar(2) NOT NULL,
  `nom` varchar(75) NOT NULL,
  `prenom` varchar(75) NOT NULL,
  `email` varchar(75) NOT NULL,
  `date_actualisation_email_utilisateur` timestamp NULL DEFAULT NULL,
  `utilisateur` varchar(25) NOT NULL,
  `mot_de_passe` varchar(9) NOT NULL,
  `telephone` varchar(15) NOT NULL,
  `mobile` varchar(15) NOT NULL,
  `adresse` varchar(255) NOT NULL,
  `code_postal` varchar(10) NOT NULL,
  `ville` varchar(75) NOT NULL,
  `pays` int NOT NULL,
  `tenant_birthday` date DEFAULT NULL COMMENT 'Tenant birthday',
  `civilite_2` varchar(2) NOT NULL,
  `nom_2` varchar(75) NOT NULL,
  `prenom_2` varchar(75) NOT NULL,
  `email_2` varchar(75) NOT NULL,
  `mobile_2` varchar(15) NOT NULL,
  `civilite_3` varchar(2) NOT NULL,
  `nom_3` varchar(75) NOT NULL,
  `prenom_3` varchar(75) NOT NULL,
  `email_3` varchar(75) NOT NULL,
  `mobile_3` varchar(15) NOT NULL,
  `civilite_4` varchar(2) NOT NULL,
  `nom_4` varchar(75) NOT NULL,
  `prenom_4` varchar(75) NOT NULL,
  `email_4` varchar(75) NOT NULL,
  `mobile_4` varchar(15) NOT NULL,
  `notes` longtext,
  `actif` tinyint(1) NOT NULL DEFAULT '1',
  `langue` varchar(2) NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `birthplace` varchar(75) DEFAULT NULL COMMENT 'Tenant birthplace',
  `birth_country` int DEFAULT NULL,
  `job_title_1` varchar(75) DEFAULT NULL,
  `job_title_2` varchar(75) DEFAULT NULL,
  `job_title_3` varchar(75) DEFAULT NULL,
  `job_title_4` varchar(75) DEFAULT NULL,
  `type` char(1) NOT NULL DEFAULT 'p' COMMENT 'Tenant type: p=personal, c=company',
  `tva_intra` varchar(32) DEFAULT NULL,
  `siren` varchar(9) DEFAULT NULL,
  `capital` decimal(15,2) DEFAULT NULL,
  `forme_juridique` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id_locataire`),
  KEY `email` (`email`,`email_2`,`email_3`,`email_4`)
) ENGINE=InnoDB AUTO_INCREMENT=19925 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_lots`
--

DROP TABLE IF EXISTS `ap_lots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_lots` (
  `id_lot` int NOT NULL AUTO_INCREMENT,
  `id_utilisateur` int NOT NULL,
  `id_entite` int DEFAULT NULL,
  `nom` varchar(75) NOT NULL,
  `nom_immeuble` varchar(75) DEFAULT NULL,
  `type` varchar(25) NOT NULL,
  `adresse` varchar(255) NOT NULL,
  `code_postal` varchar(10) NOT NULL,
  `ville` varchar(75) NOT NULL,
  `pays` int NOT NULL,
  `surface` decimal(12,2) DEFAULT NULL,
  `surface_unites` varchar(3) NOT NULL,
  `batiment` varchar(5) DEFAULT NULL,
  `etage` int DEFAULT NULL,
  `dpe_c` varchar(1) DEFAULT NULL,
  `dpe_e` varchar(1) DEFAULT NULL,
  `tantiemes` int DEFAULT NULL,
  `tantiemes_total` int DEFAULT NULL,
  `date_achat` timestamp NULL DEFAULT NULL,
  `prix_achat` decimal(12,2) DEFAULT NULL,
  `devise` varchar(5) NOT NULL,
  `nom_syndic` varchar(75) NOT NULL,
  `telephone_syndic` varchar(15) NOT NULL,
  `email_syndic` varchar(75) NOT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT '1',
  `date_inactif` date DEFAULT NULL,
  `date_creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `energy_class` varchar(1) DEFAULT NULL COMMENT 'Energy class (A, B, C, D, E, F, G)',
  `fiscal_number` varchar(255) DEFAULT NULL,
  `building_type` varchar(255) DEFAULT NULL,
  `building_constuction_date` varchar(255) DEFAULT NULL,
  `rooms_count` smallint DEFAULT NULL,
  `additional_unit_perks` varchar(255) DEFAULT NULL,
  `additional_unit_perks_other` varchar(255) DEFAULT NULL,
  `unit_equipments` varchar(255) DEFAULT NULL,
  `unit_equipments_sn` varchar(255) DEFAULT NULL,
  `unit_equipments_ot` varchar(255) DEFAULT NULL,
  `shared_heating` varchar(20) DEFAULT NULL,
  `shared_heating_repartition` varchar(255) DEFAULT NULL,
  `shared_water_heating` varchar(20) DEFAULT NULL,
  `shared_water_heating_repartition` varchar(255) DEFAULT NULL,
  `unit_usage` varchar(255) DEFAULT NULL,
  `ancillary_cave` tinyint(1) DEFAULT NULL,
  `ancillary_cave_number` varchar(255) DEFAULT NULL,
  `ancillary_parking` tinyint(1) DEFAULT NULL,
  `ancillary_parking_number` varchar(255) DEFAULT NULL,
  `ancillary_garage` tinyint(1) DEFAULT NULL,
  `ancillary_garage_number` varchar(255) DEFAULT NULL,
  `ancillary_other` tinyint(1) DEFAULT NULL,
  `ancillary_other_text` varchar(255) DEFAULT NULL,
  `common_bike_storage` tinyint(1) DEFAULT NULL,
  `common_elevator` tinyint(1) DEFAULT NULL,
  `common_green_space` tinyint(1) DEFAULT NULL,
  `common_play_areas` tinyint(1) DEFAULT NULL,
  `common_laundry` tinyint(1) DEFAULT NULL,
  `common_waste_room` tinyint(1) DEFAULT NULL,
  `common_security` tinyint(1) DEFAULT NULL,
  `common_other_services` tinyint(1) DEFAULT NULL,
  `common_other_services_text` varchar(255) DEFAULT NULL,
  `ntic` text,
  `escalier` varchar(255) DEFAULT NULL,
  `porte` varchar(255) DEFAULT NULL,
  `ancillary_box` tinyint(1) DEFAULT NULL,
  `ancillary_box_number` varchar(255) DEFAULT NULL,
  `ancillary_reserve` tinyint(1) DEFAULT NULL,
  `ancillary_reserve_number` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_lot`),
  KEY `id_utilisateur` (`id_utilisateur`),
  KEY `date_achat` (`date_achat`)
) ENGINE=InnoDB AUTO_INCREMENT=19503 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_mentions_legales`
--

DROP TABLE IF EXISTS `ap_mentions_legales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_mentions_legales` (
  `id_mentions_legales` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `titre_page_fr` varchar(255) DEFAULT NULL,
  `titre_page_en` varchar(255) DEFAULT NULL,
  `meta_description_fr` varchar(255) DEFAULT NULL,
  `meta_description_en` varchar(255) DEFAULT NULL,
  `texte_fr` longtext,
  `texte_en` longtext,
  PRIMARY KEY (`id_mentions_legales`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_messages`
--

DROP TABLE IF EXISTS `ap_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_messages` (
  `id_message` int NOT NULL AUTO_INCREMENT,
  `id_utilisateur_emmeteur` int DEFAULT NULL,
  `ids_utilisateurs_destinataires` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `ids_utilisateurs_lus` varchar(255) DEFAULT NULL,
  `ids_utilisateurs_supprimes` varchar(255) DEFAULT NULL,
  `emmeteur_email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `emmeteur_nom` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `destinataires_email` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `sujet` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `message_body` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `message_footer` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `date_envoi` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_message`)
) ENGINE=InnoDB AUTO_INCREMENT=2111 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_modeles`
--

DROP TABLE IF EXISTS `ap_modeles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_modeles` (
  `id_modele_de_document` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `fichier` varchar(255) DEFAULT NULL,
  `nom_fichier` varchar(255) DEFAULT NULL,
  `categories` int DEFAULT NULL,
  PRIMARY KEY (`id_modele_de_document`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_nuitees`
--

DROP TABLE IF EXISTS `ap_nuitees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_nuitees` (
  `id_nuitee` int NOT NULL AUTO_INCREMENT,
  `id_locataire` int NOT NULL,
  `id_utilisateur` int NOT NULL,
  `id_entite` int NOT NULL,
  `id_lot_1` int DEFAULT NULL,
  `id_lot_2` int DEFAULT NULL,
  `id_lot_3` int DEFAULT NULL,
  `id_lot_4` int DEFAULT NULL,
  `titulaires` longtext,
  `notes` longtext,
  `langue` varchar(2) NOT NULL,
  `devise` varchar(5) NOT NULL,
  `date_entree` timestamp NULL DEFAULT NULL,
  `date_sortie` timestamp NULL DEFAULT NULL,
  `cout_nuitee` decimal(12,2) DEFAULT NULL,
  `montant_total` decimal(12,2) DEFAULT NULL,
  `montant_facture` decimal(12,2) DEFAULT NULL,
  `caution_montant` decimal(12,2) DEFAULT NULL,
  `taxe` varchar(50) DEFAULT NULL,
  `taxe_taux` decimal(5,2) DEFAULT NULL,
  `autre_poste_1` varchar(100) NOT NULL,
  `autre_poste_montant_1` decimal(12,2) DEFAULT NULL,
  `autre_poste_taxe_1` int NOT NULL,
  `autre_poste_2` varchar(100) NOT NULL,
  `autre_poste_montant_2` decimal(12,2) DEFAULT NULL,
  `autre_poste_taxe_2` int NOT NULL,
  `autre_poste_3` varchar(100) NOT NULL,
  `autre_poste_montant_3` decimal(12,2) DEFAULT NULL,
  `autre_poste_taxe_3` int NOT NULL,
  `autre_poste_4` varchar(100) NOT NULL,
  `autre_poste_montant_4` decimal(12,2) DEFAULT NULL,
  `autre_poste_taxe_4` int NOT NULL,
  `autre_poste_5` varchar(100) DEFAULT NULL,
  `autre_poste_montant_5` decimal(12,2) DEFAULT NULL,
  `autre_poste_taxe_5` int NOT NULL,
  `quittance_message` longtext NOT NULL,
  `reference` varchar(255) DEFAULT NULL,
  `email_copie_utilisateur` tinyint(1) NOT NULL,
  `email_copie_comptable` tinyint(1) NOT NULL,
  `email_copie` longtext NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `poids_nuitee` int DEFAULT NULL,
  `date_envoi` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_nuitee`),
  KEY `id_locataire` (`id_locataire`),
  KEY `id_lot_1` (`id_lot_1`),
  KEY `id_lot_2` (`id_lot_2`),
  KEY `id_lot_3` (`id_lot_3`),
  KEY `id_lot_4` (`id_lot_4`),
  KEY `date_sortie` (`date_sortie`)
) ENGINE=InnoDB AUTO_INCREMENT=1537 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_nuitees_postes`
--

DROP TABLE IF EXISTS `ap_nuitees_postes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_nuitees_postes` (
  `id_poste` int NOT NULL AUTO_INCREMENT,
  `id_nuitee` int NOT NULL,
  `id_locataire` int NOT NULL,
  `id_entite` int NOT NULL,
  `id_utilisateur` int NOT NULL,
  `proprietaire` varchar(255) NOT NULL,
  `locataire` varchar(255) NOT NULL,
  `adresse_locataire` varchar(255) NOT NULL,
  `date_creation` timestamp NOT NULL,
  `periode_debut` date NOT NULL,
  `periode_fin` date NOT NULL,
  `reference` varchar(255) NOT NULL,
  `poste` varchar(255) NOT NULL,
  `type` varchar(25) NOT NULL,
  `montant` decimal(12,2) NOT NULL,
  `montant_facture` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id_poste`)
) ENGINE=InnoDB AUTO_INCREMENT=5378 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_objets_contact`
--

DROP TABLE IF EXISTS `ap_objets_contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_objets_contact` (
  `id_objet` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `objet_message_fr` varchar(255) DEFAULT NULL,
  `objet_message_en` varchar(255) DEFAULT NULL,
  `suggestion_fr` longtext,
  `suggestion_en` longtext,
  `destinataires` int DEFAULT NULL,
  `objet_liste_fr` varchar(255) DEFAULT NULL,
  `objet_liste_en` varchar(255) DEFAULT NULL,
  `emetteurs` int DEFAULT NULL,
  PRIMARY KEY (`id_objet`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_options`
--

DROP TABLE IF EXISTS `ap_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_options` (
  `id_option` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `nom_fr` varchar(255) DEFAULT NULL,
  `nom_en` varchar(255) DEFAULT NULL,
  `description_fr` longtext,
  `description_en` longtext,
  PRIMARY KEY (`id_option`)
) ENGINE=InnoDB AUTO_INCREMENT=100000 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_orias_cards`
--

DROP TABLE IF EXISTS `ap_orias_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_orias_cards` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_entite` int unsigned NOT NULL,
  `card_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_id_entite` (`id_entite`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_page_modeles`
--

DROP TABLE IF EXISTS `ap_page_modeles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_page_modeles` (
  `id_page_modeles` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `titre_page_fr` varchar(255) DEFAULT NULL,
  `titre_page_en` varchar(255) DEFAULT NULL,
  `meta_description_fr` varchar(255) DEFAULT NULL,
  `meta_description_en` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_page_modeles`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_pays`
--

DROP TABLE IF EXISTS `ap_pays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_pays` (
  `id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `code` int NOT NULL,
  `alpha2` varchar(2) NOT NULL,
  `alpha3` varchar(3) NOT NULL,
  `nom_en` varchar(45) NOT NULL,
  `nom_fr` varchar(45) NOT NULL,
  `nationalite_m` varchar(60) DEFAULT NULL,
  `nationalite_f` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `alpha2` (`alpha2`),
  UNIQUE KEY `alpha3` (`alpha3`),
  UNIQUE KEY `code_unique` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=244 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_preferences`
--

DROP TABLE IF EXISTS `ap_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_preferences` (
  `id_preference` int NOT NULL AUTO_INCREMENT,
  `couleur_principale` varchar(7) DEFAULT NULL,
  `couleur_secondaire` varchar(7) DEFAULT NULL,
  `couleur_ligne_sombre` varchar(7) DEFAULT NULL,
  `couleur_bouton_primaire` varchar(7) DEFAULT NULL,
  `couleur_bouton_primaire_contour` varchar(7) DEFAULT NULL,
  `couleur_bouton_primaire_survol` varchar(7) DEFAULT NULL,
  `couleur_bouton_primaire_contour_survol` varchar(7) DEFAULT NULL,
  `couleur_bouton_primaire_clic` varchar(7) DEFAULT NULL,
  `couleur_bouton_primaire_contour_clic` varchar(7) DEFAULT NULL,
  `couleur_lien` varchar(7) DEFAULT NULL,
  `date_modification` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_preference`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_professional_cards`
--

DROP TABLE IF EXISTS `ap_professional_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_professional_cards` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_entite` int unsigned NOT NULL,
  `card_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_id_entite` (`id_entite`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_screenshots`
--

DROP TABLE IF EXISTS `ap_screenshots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_screenshots` (
  `id_screenshots` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `nom_image` varchar(255) DEFAULT NULL,
  `format_image` varchar(5) DEFAULT NULL,
  `largeur_image` int DEFAULT NULL,
  `hauteur_image` int DEFAULT NULL,
  PRIMARY KEY (`id_screenshots`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_tables_associations`
--

DROP TABLE IF EXISTS `ap_tables_associations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_tables_associations` (
  `id_association` int NOT NULL AUTO_INCREMENT,
  `id_table_element_parent` int NOT NULL,
  `id_element_parent` int NOT NULL,
  `id_table_element` int NOT NULL,
  `id_element` int NOT NULL,
  PRIMARY KEY (`id_association`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_tables_champs`
--

DROP TABLE IF EXISTS `ap_tables_champs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_tables_champs` (
  `id_champ` int NOT NULL AUTO_INCREMENT,
  `id_table_description` int NOT NULL,
  `nom` varchar(255) NOT NULL,
  `label` varchar(255) NOT NULL,
  `info_complementaire` varchar(255) DEFAULT NULL,
  `type_donnee` varchar(255) NOT NULL,
  `type_input` varchar(25) DEFAULT NULL,
  `valeur_defaut` varchar(255) DEFAULT NULL,
  `id_table_liste_choix` int DEFAULT NULL,
  `min_liste_choix` int DEFAULT NULL,
  `max_liste_choix` int DEFAULT NULL,
  `cache` tinyint(1) NOT NULL,
  `lecture_seulement` tinyint(1) NOT NULL,
  `groupe_donnee` varchar(50) DEFAULT NULL,
  `requis` tinyint(1) NOT NULL,
  `nombre_caracteres` int DEFAULT NULL,
  `icone` varchar(255) DEFAULT NULL,
  `section` varchar(255) DEFAULT NULL,
  `ordre` int NOT NULL,
  PRIMARY KEY (`id_champ`)
) ENGINE=InnoDB AUTO_INCREMENT=247 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_tables_descriptions`
--

DROP TABLE IF EXISTS `ap_tables_descriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_tables_descriptions` (
  `id_table_description` int NOT NULL AUTO_INCREMENT,
  `nom_table` varchar(255) NOT NULL,
  `nom_id` varchar(255) NOT NULL,
  `singulier` varchar(255) NOT NULL,
  `pluriel` varchar(255) NOT NULL,
  `genre` varchar(1) NOT NULL,
  `type_enregistrement` varchar(1) NOT NULL,
  `id_table_parente` int DEFAULT NULL,
  `icone` varchar(255) DEFAULT NULL,
  `date_creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `ordre` int NOT NULL,
  PRIMARY KEY (`id_table_description`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_taxes`
--

DROP TABLE IF EXISTS `ap_taxes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_taxes` (
  `id_taxe` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `taux` varchar(255) DEFAULT NULL,
  `nom_taxe_fr` varchar(255) DEFAULT NULL,
  `nom_taxe_en` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_taxe`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_temoignages`
--

DROP TABLE IF EXISTS `ap_temoignages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_temoignages` (
  `id_temoignage` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `fonction_fr` varchar(255) DEFAULT NULL,
  `temoignage_fr` longtext,
  `identite` varchar(255) DEFAULT NULL,
  `fonction_en` varchar(255) DEFAULT NULL,
  `temoignage_en` longtext,
  `image` varchar(255) DEFAULT NULL,
  `nom_image` varchar(255) DEFAULT NULL,
  `largeur_image` int DEFAULT NULL,
  `hauteur_image` int DEFAULT NULL,
  `format_image` varchar(5) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_temoignage`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_tentatives_connexion`
--

DROP TABLE IF EXISTS `ap_tentatives_connexion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_tentatives_connexion` (
  `id_tentative` int NOT NULL AUTO_INCREMENT,
  `ip_remote` varchar(45) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `nombre_tentatives` int NOT NULL,
  `date_tentative` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `utilisateur` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id_tentative`)
) ENGINE=InnoDB AUTO_INCREMENT=1468 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_tentatives_connexion_users`
--

DROP TABLE IF EXISTS `ap_tentatives_connexion_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_tentatives_connexion_users` (
  `id_tentative` int NOT NULL AUTO_INCREMENT,
  `date_tentative` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `ip_remote` varchar(45) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `resultat` tinyint(1) NOT NULL,
  `id_utilisateur` int DEFAULT NULL,
  `nature_erreur` varchar(12) DEFAULT NULL,
  `utilisateur_saisi` varchar(75) DEFAULT NULL,
  PRIMARY KEY (`id_tentative`)
) ENGINE=InnoDB AUTO_INCREMENT=167600 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_trimestres`
--

DROP TABLE IF EXISTS `ap_trimestres`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_trimestres` (
  `id_trimestre` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `nom_aseptise` varchar(255) DEFAULT NULL,
  `etat` tinyint(1) DEFAULT NULL,
  `id_element_parent` int DEFAULT NULL,
  `ordre` int NOT NULL,
  `date_creation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_utilisateur_creation` int NOT NULL,
  `id_utilisateur_modification` int NOT NULL,
  `trimestre` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_trimestre`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_users`
--

DROP TABLE IF EXISTS `ap_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_users` (
  `id_utilisateur` int NOT NULL AUTO_INCREMENT,
  `civilite` varchar(3) NOT NULL,
  `utilisateur` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `prenom` varchar(75) NOT NULL,
  `nom` varchar(75) NOT NULL,
  `email` varchar(255) NOT NULL,
  `date_actualisation_email_utilisateur` timestamp NULL DEFAULT NULL,
  `telephone` varchar(255) NOT NULL,
  `mobile` varchar(255) NOT NULL,
  `langue` varchar(2) DEFAULT NULL,
  `mot_de_passe` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `type` varchar(14) NOT NULL,
  `id_type` int DEFAULT NULL,
  `id_utilisateur_parent` int DEFAULT NULL,
  `id_recuperation` varchar(255) DEFAULT NULL,
  `date_demande_recuperation` timestamp NULL DEFAULT NULL,
  `id_activation` varchar(255) DEFAULT NULL,
  `date_demande_activation` timestamp NULL DEFAULT NULL,
  `date_activation` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `etat_activation` tinyint(1) NOT NULL,
  `date_modification` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `adresse_ip` varchar(255) NOT NULL,
  `stripe_customer_id` varchar(64) DEFAULT NULL,
  `cacher_identifiants_locataires` tinyint(1) DEFAULT NULL,
  `couleur` varchar(7) DEFAULT NULL,
  `couleur_texte` varchar(7) DEFAULT NULL,
  `prenom_facturation` varchar(75) DEFAULT NULL,
  `nom_facturation` varchar(75) DEFAULT NULL,
  `adresse_facturation` varchar(255) DEFAULT NULL,
  `code_postal_facturation` varchar(10) DEFAULT NULL,
  `ville_facturation` varchar(75) DEFAULT NULL,
  `pays_facturation` int DEFAULT NULL,
  PRIMARY KEY (`id_utilisateur`),
  KEY `id_type` (`id_type`),
  KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=100000 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_users_factures`
--

DROP TABLE IF EXISTS `ap_users_factures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_users_factures` (
  `id_user_facture` int NOT NULL AUTO_INCREMENT,
  `invoice_id` varchar(64) NOT NULL,
  `customer_id` varchar(64) NOT NULL,
  `subscription_id` varchar(64) NOT NULL,
  `payment_intent` varchar(64) DEFAULT NULL,
  `price_id` varchar(64) NOT NULL,
  `period_start` int NOT NULL,
  `period_end` int NOT NULL,
  `amount_due` int DEFAULT NULL,
  `paid_at` int DEFAULT NULL,
  `status` varchar(64) NOT NULL,
  `invoice_pdf` varchar(255) NOT NULL,
  `local_invoice_pdf` varchar(64) NOT NULL,
  `hosted_invoice_url` varchar(255) NOT NULL,
  PRIMARY KEY (`id_user_facture`)
) ENGINE=InnoDB AUTO_INCREMENT=252 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_users_formules`
--

DROP TABLE IF EXISTS `ap_users_formules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_users_formules` (
  `id_user_formule` int NOT NULL AUTO_INCREMENT,
  `stripe_customer_id` varchar(64) NOT NULL,
  `stripe_subscription_id` varchar(64) DEFAULT NULL,
  `stripe_client_secret` varchar(64) DEFAULT NULL,
  `stripe_invoice_id` varchar(64) DEFAULT NULL,
  `stripe_price_id` varchar(64) DEFAULT NULL,
  `stripe_plan_amount` int DEFAULT NULL,
  `stripe_amount_paid` int DEFAULT NULL,
  `stripe_current_period_start` int DEFAULT NULL,
  `stripe_current_period_end` int DEFAULT NULL,
  `stripe_payment_time` int DEFAULT NULL,
  `stripe_cancel_time` int DEFAULT NULL,
  `stripe_upcoming_invoice_time` int DEFAULT NULL,
  `stripe_upcoming_invoice_amount` int DEFAULT NULL,
  PRIMARY KEY (`id_user_formule`)
) ENGINE=InnoDB AUTO_INCREMENT=223 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_utilisateurs`
--

DROP TABLE IF EXISTS `ap_utilisateurs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_utilisateurs` (
  `id_utilisateur` int NOT NULL AUTO_INCREMENT,
  `utilisateur` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `prenom` varchar(255) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `mot_de_passe` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `type` varchar(25) NOT NULL,
  `id_recuperation` varchar(255) DEFAULT NULL,
  `date_demande_recuperation` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_utilisateur`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_vacance_lots`
--

DROP TABLE IF EXISTS `ap_vacance_lots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_vacance_lots` (
  `id_vacance` int unsigned NOT NULL AUTO_INCREMENT,
  `id_entite` int NOT NULL,
  `date` date NOT NULL,
  `nombre_lots` int NOT NULL,
  `nombre_lots_occupes` int NOT NULL,
  PRIMARY KEY (`id_vacance`),
  KEY `id_entite` (`id_entite`)
) ENGINE=InnoDB AUTO_INCREMENT=1055370 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_verrous_modification`
--

DROP TABLE IF EXISTS `ap_verrous_modification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ap_verrous_modification` (
  `id_verrou` int NOT NULL AUTO_INCREMENT,
  `id_utilisateur` int NOT NULL,
  `nom_table` varchar(255) NOT NULL,
  `id_element` int NOT NULL,
  `etat` varchar(10) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL DEFAULT 'verrouille',
  `date_verrou` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_verrou`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_commentmeta`
--

DROP TABLE IF EXISTS `wpap_commentmeta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_commentmeta` (
  `meta_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `comment_id` bigint unsigned NOT NULL DEFAULT '0',
  `meta_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `meta_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`meta_id`),
  KEY `comment_id` (`comment_id`),
  KEY `meta_key` (`meta_key`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_comments`
--

DROP TABLE IF EXISTS `wpap_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_comments` (
  `comment_ID` bigint unsigned NOT NULL AUTO_INCREMENT,
  `comment_post_ID` bigint unsigned NOT NULL DEFAULT '0',
  `comment_author` tinytext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `comment_author_email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `comment_author_url` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `comment_author_IP` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `comment_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `comment_date_gmt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `comment_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `comment_karma` int NOT NULL DEFAULT '0',
  `comment_approved` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '1',
  `comment_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `comment_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'comment',
  `comment_parent` bigint unsigned NOT NULL DEFAULT '0',
  `user_id` bigint unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`comment_ID`),
  KEY `comment_post_ID` (`comment_post_ID`),
  KEY `comment_approved_date_gmt` (`comment_approved`,`comment_date_gmt`),
  KEY `comment_date_gmt` (`comment_date_gmt`),
  KEY `comment_parent` (`comment_parent`),
  KEY `comment_author_email` (`comment_author_email`(10))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_csp3_subscribers`
--

DROP TABLE IF EXISTS `wpap_csp3_subscribers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_csp3_subscribers` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `page_id` int NOT NULL,
  `page_uuid` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `fname` varchar(255) DEFAULT NULL,
  `lname` varchar(255) DEFAULT NULL,
  `ref_url` varchar(255) DEFAULT NULL,
  `clicks` int NOT NULL DEFAULT '0',
  `conversions` int NOT NULL DEFAULT '0',
  `referrer` int NOT NULL DEFAULT '0',
  `confirmed` int NOT NULL DEFAULT '0',
  `optin_confirm` int NOT NULL DEFAULT '0',
  `ip` varchar(255) DEFAULT NULL,
  `meta` text,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `csp3_subscribers_page_uuid_idx` (`page_uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_links`
--

DROP TABLE IF EXISTS `wpap_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_links` (
  `link_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `link_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_target` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_visible` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'Y',
  `link_owner` bigint unsigned NOT NULL DEFAULT '1',
  `link_rating` int NOT NULL DEFAULT '0',
  `link_updated` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `link_rel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_notes` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `link_rss` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`link_id`),
  KEY `link_visible` (`link_visible`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_options`
--

DROP TABLE IF EXISTS `wpap_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_options` (
  `option_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `option_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `option_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `autoload` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'yes',
  PRIMARY KEY (`option_id`),
  UNIQUE KEY `option_name` (`option_name`),
  KEY `autoload` (`autoload`)
) ENGINE=InnoDB AUTO_INCREMENT=105677 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_postmeta`
--

DROP TABLE IF EXISTS `wpap_postmeta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_postmeta` (
  `meta_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `post_id` bigint unsigned NOT NULL DEFAULT '0',
  `meta_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `meta_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`meta_id`),
  KEY `post_id` (`post_id`),
  KEY `meta_key` (`meta_key`(191))
) ENGINE=InnoDB AUTO_INCREMENT=2865 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_posts`
--

DROP TABLE IF EXISTS `wpap_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_posts` (
  `ID` bigint unsigned NOT NULL AUTO_INCREMENT,
  `post_author` bigint unsigned NOT NULL DEFAULT '0',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_date_gmt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_title` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_excerpt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'publish',
  `comment_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'open',
  `ping_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'open',
  `post_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `post_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `to_ping` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `pinged` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_modified_gmt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_content_filtered` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_parent` bigint unsigned NOT NULL DEFAULT '0',
  `guid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `menu_order` int NOT NULL DEFAULT '0',
  `post_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'post',
  `post_mime_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `comment_count` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `post_name` (`post_name`(191)),
  KEY `type_status_date` (`post_type`,`post_status`,`post_date`,`ID`),
  KEY `post_parent` (`post_parent`),
  KEY `post_author` (`post_author`)
) ENGINE=InnoDB AUTO_INCREMENT=901 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_smush_dir_images`
--

DROP TABLE IF EXISTS `wpap_smush_dir_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_smush_dir_images` (
  `id` mediumint NOT NULL AUTO_INCREMENT,
  `path` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `path_hash` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `resize` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `lossy` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `error` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `image_size` int unsigned DEFAULT NULL,
  `orig_size` int unsigned DEFAULT NULL,
  `file_time` int unsigned DEFAULT NULL,
  `last_scan` timestamp NULL DEFAULT '0000-00-00 00:00:00',
  `meta` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `path_hash` (`path_hash`),
  KEY `image_size` (`image_size`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_term_relationships`
--

DROP TABLE IF EXISTS `wpap_term_relationships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_term_relationships` (
  `object_id` bigint unsigned NOT NULL DEFAULT '0',
  `term_taxonomy_id` bigint unsigned NOT NULL DEFAULT '0',
  `term_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`object_id`,`term_taxonomy_id`),
  KEY `term_taxonomy_id` (`term_taxonomy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_term_taxonomy`
--

DROP TABLE IF EXISTS `wpap_term_taxonomy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_term_taxonomy` (
  `term_taxonomy_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `term_id` bigint unsigned NOT NULL DEFAULT '0',
  `taxonomy` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `parent` bigint unsigned NOT NULL DEFAULT '0',
  `count` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`term_taxonomy_id`),
  UNIQUE KEY `term_id_taxonomy` (`term_id`,`taxonomy`),
  KEY `taxonomy` (`taxonomy`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_termmeta`
--

DROP TABLE IF EXISTS `wpap_termmeta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_termmeta` (
  `meta_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `term_id` bigint unsigned NOT NULL DEFAULT '0',
  `meta_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `meta_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`meta_id`),
  KEY `term_id` (`term_id`),
  KEY `meta_key` (`meta_key`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_terms`
--

DROP TABLE IF EXISTS `wpap_terms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_terms` (
  `term_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `slug` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `term_group` bigint NOT NULL DEFAULT '0',
  `term_order` int DEFAULT '0',
  PRIMARY KEY (`term_id`),
  KEY `slug` (`slug`(191)),
  KEY `name` (`name`(191))
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_usermeta`
--

DROP TABLE IF EXISTS `wpap_usermeta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_usermeta` (
  `umeta_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL DEFAULT '0',
  `meta_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `meta_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`umeta_id`),
  KEY `user_id` (`user_id`),
  KEY `meta_key` (`meta_key`(191))
) ENGINE=InnoDB AUTO_INCREMENT=161 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_users`
--

DROP TABLE IF EXISTS `wpap_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_users` (
  `ID` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_login` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `user_pass` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `user_nicename` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `user_email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `user_url` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `user_registered` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `user_activation_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `user_status` int NOT NULL DEFAULT '0',
  `display_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`),
  KEY `user_login_key` (`user_login`),
  KEY `user_nicename` (`user_nicename`),
  KEY `user_email` (`user_email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_yoast_indexable`
--

DROP TABLE IF EXISTS `wpap_yoast_indexable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_yoast_indexable` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `permalink` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  `permalink_hash` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `object_id` bigint DEFAULT NULL,
  `object_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `object_sub_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `author_id` bigint DEFAULT NULL,
  `post_parent` bigint DEFAULT NULL,
  `title` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  `description` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  `breadcrumb_title` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  `post_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT NULL,
  `is_protected` tinyint(1) DEFAULT '0',
  `has_public_posts` tinyint(1) DEFAULT NULL,
  `number_of_pages` int unsigned DEFAULT NULL,
  `canonical` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  `primary_focus_keyword` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `primary_focus_keyword_score` int DEFAULT NULL,
  `readability_score` int DEFAULT NULL,
  `is_cornerstone` tinyint(1) DEFAULT '0',
  `is_robots_noindex` tinyint(1) DEFAULT '0',
  `is_robots_nofollow` tinyint(1) DEFAULT '0',
  `is_robots_noarchive` tinyint(1) DEFAULT '0',
  `is_robots_noimageindex` tinyint(1) DEFAULT '0',
  `is_robots_nosnippet` tinyint(1) DEFAULT '0',
  `twitter_title` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  `twitter_image` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  `twitter_description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  `twitter_image_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `twitter_image_source` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  `open_graph_title` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  `open_graph_description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  `open_graph_image` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  `open_graph_image_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `open_graph_image_source` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  `open_graph_image_meta` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  `link_count` int DEFAULT NULL,
  `incoming_link_count` int DEFAULT NULL,
  `prominent_words_version` int unsigned DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `blog_id` bigint NOT NULL DEFAULT '1',
  `language` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `region` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `schema_page_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `schema_article_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `has_ancestors` tinyint(1) DEFAULT '0',
  `estimated_reading_time_minutes` int DEFAULT NULL,
  `version` int DEFAULT '1',
  `object_last_modified` datetime DEFAULT NULL,
  `object_published_at` datetime DEFAULT NULL,
  `inclusive_language_score` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `object_type_and_sub_type` (`object_type`,`object_sub_type`),
  KEY `object_id_and_type` (`object_id`,`object_type`),
  KEY `subpages` (`post_parent`,`object_type`,`post_status`,`object_id`),
  KEY `permalink_hash_and_object_type` (`permalink_hash`,`object_type`),
  KEY `prominent_words` (`prominent_words_version`,`object_type`,`object_sub_type`,`post_status`),
  KEY `published_sitemap_index` (`object_published_at`,`is_robots_noindex`,`object_type`,`object_sub_type`)
) ENGINE=InnoDB AUTO_INCREMENT=208 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_yoast_indexable_hierarchy`
--

DROP TABLE IF EXISTS `wpap_yoast_indexable_hierarchy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_yoast_indexable_hierarchy` (
  `indexable_id` int unsigned NOT NULL DEFAULT '0',
  `ancestor_id` int unsigned NOT NULL DEFAULT '0',
  `depth` int unsigned DEFAULT NULL,
  `blog_id` bigint NOT NULL DEFAULT '1',
  PRIMARY KEY (`indexable_id`,`ancestor_id`),
  KEY `indexable_id` (`indexable_id`),
  KEY `ancestor_id` (`ancestor_id`),
  KEY `depth` (`depth`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_yoast_migrations`
--

DROP TABLE IF EXISTS `wpap_yoast_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_yoast_migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `version` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_wpap_yoast_migrations_version` (`version`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_yoast_primary_term`
--

DROP TABLE IF EXISTS `wpap_yoast_primary_term`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_yoast_primary_term` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `post_id` bigint DEFAULT NULL,
  `term_id` bigint DEFAULT NULL,
  `taxonomy` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `blog_id` bigint NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `post_taxonomy` (`post_id`,`taxonomy`),
  KEY `post_term` (`post_id`,`term_id`)
) ENGINE=InnoDB AUTO_INCREMENT=128 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_yoast_seo_links`
--

DROP TABLE IF EXISTS `wpap_yoast_seo_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_yoast_seo_links` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_id` bigint unsigned NOT NULL,
  `target_post_id` bigint unsigned NOT NULL,
  `type` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `indexable_id` int unsigned DEFAULT NULL,
  `target_indexable_id` int unsigned DEFAULT NULL,
  `height` int unsigned DEFAULT NULL,
  `width` int unsigned DEFAULT NULL,
  `size` int unsigned DEFAULT NULL,
  `language` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `region` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `link_direction` (`post_id`,`type`),
  KEY `indexable_link_direction` (`indexable_id`,`type`)
) ENGINE=InnoDB AUTO_INCREMENT=5362 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `wpap_yoast_seo_meta`
--

DROP TABLE IF EXISTS `wpap_yoast_seo_meta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wpap_yoast_seo_meta` (
  `object_id` bigint unsigned NOT NULL,
  `internal_link_count` int unsigned DEFAULT NULL,
  `incoming_link_count` int unsigned DEFAULT NULL,
  UNIQUE KEY `object_id` (`object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'appliceo_php'
--
/*!50003 DROP PROCEDURE IF EXISTS `migration_error_handler` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`appliceo`@`%` PROCEDURE `migration_error_handler`(IN error_message TEXT)
BEGIN
    
    SELECT CONCAT('MIGRATION ERROR: ', error_message, ' at ', NOW()) as error_message;

    
    ROLLBACK;

    
    SET autocommit = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-30 21:45:30
