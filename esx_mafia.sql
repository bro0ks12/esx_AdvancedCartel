INSERT INTO `addon_account` (name, label, shared) VALUES 
('society_mafia','Mafia',1);

INSERT INTO `datastore` (name, label, shared) VALUES 
('society_mafia','Mafia',1);

INSERT INTO `addon_inventory` (name, label, shared) VALUES 
('society_mafia', 'Mafia', 1);

INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES
('mafia', 'Mafia', 1);

INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('mafia', 0, 'prospect', 'Prospect', 1000, '{}', '{}'),
('mafia', 1, 'soldier', 'Soldier', 1300, '{}', '{}'),
('mafia', 2, 'vp', 'Vice President', 1500, '{}', '{}'),
('mafia', 3, 'boss', 'President', 2700, '{}', '{}');