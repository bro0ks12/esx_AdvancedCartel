INSERT INTO `addon_account` (name, label, shared) VALUES 
('society_cartel','Cartel',1);

INSERT INTO `datastore` (name, label, shared) VALUES 
('society_cartel','Cartel',1);

INSERT INTO `addon_inventory` (name, label, shared) VALUES 
('society_cartel', 'Cartel', 1);

INSERT INTO `jobs` (`name`, `label`) VALUES
('cartel', 'Cartel');

INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('cartel', 0, 'prospect', 'Prospect', 1000, '{}', '{}'),
('cartel', 1, 'soldier', 'Soldier', 1300, '{}', '{}'),
('cartel', 2, 'vp', 'Vice President', 1500, '{}', '{}'),
('cartel', 3, 'boss', 'President', 2700, '{}', '{}');