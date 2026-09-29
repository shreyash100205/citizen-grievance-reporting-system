-- Project 2: Citizen Grievance Data Management & Reporting System
-- Database: MySQL 8.0+ (uses window functions). Sample data only - randomly generated, not real.
-- HOW TO RUN: CREATE DATABASE grievance_db; USE grievance_db; then run this file.
-- Report date used for 'overdue' and 'future date' logic: 2026-09-29.

-- ============ PART 1: TABLES AND SAMPLE DATA ============
CREATE TABLE wards (
  ward_code VARCHAR(5)  PRIMARY KEY,
  ward_name VARCHAR(50) NOT NULL
);
CREATE TABLE categories (
  category_id   INT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL UNIQUE,
  department    VARCHAR(50) NOT NULL
);
CREATE TABLE priorities (
  priority VARCHAR(10) PRIMARY KEY,
  sla_days INT NOT NULL
);
-- raw complaints exactly as entered (contains errors on purpose)
CREATE TABLE staging_complaints (
  stg_id        INT PRIMARY KEY,
  complaint_id  VARCHAR(20),
  date_logged   VARCHAR(10),      -- 'YYYY-MM-DD'
  ward_code     VARCHAR(5),
  category_name VARCHAR(50),
  priority      VARCHAR(10),
  status        VARCHAR(15),
  assigned_to   VARCHAR(30),
  date_resolved VARCHAR(10)
);
-- clean table with constraints
CREATE TABLE complaints (
  complaint_id  VARCHAR(20) PRIMARY KEY,
  date_logged   DATE        NOT NULL,
  ward_code     VARCHAR(5)  NOT NULL,
  category_id   INT         NOT NULL,
  priority      VARCHAR(10) NOT NULL,
  status        VARCHAR(15) NOT NULL,
  assigned_to   VARCHAR(30) NULL,
  date_resolved DATE        NULL,
  FOREIGN KEY (ward_code)   REFERENCES wards(ward_code),
  FOREIGN KEY (category_id) REFERENCES categories(category_id),
  FOREIGN KEY (priority)    REFERENCES priorities(priority)
);
-- rows that failed validation, with the reason
CREATE TABLE rejected_complaints (
  stg_id        INT PRIMARY KEY,
  complaint_id  VARCHAR(20),
  reject_reason VARCHAR(40)
);
INSERT INTO wards VALUES ('W01', 'Shivaji Nagar');
INSERT INTO wards VALUES ('W02', 'Gandhi Nagar');
INSERT INTO wards VALUES ('W03', 'Nehru Colony');
INSERT INTO wards VALUES ('W04', 'Ambedkar Nagar');
INSERT INTO wards VALUES ('W05', 'Tilak Road');
INSERT INTO wards VALUES ('W06', 'Laxmi Nagar');
INSERT INTO wards VALUES ('W07', 'Station Area');
INSERT INTO wards VALUES ('W08', 'Market Yard');
INSERT INTO categories VALUES (1, 'Water Supply', 'Water Dept');
INSERT INTO categories VALUES (2, 'Drainage & Sewage', 'Drainage Dept');
INSERT INTO categories VALUES (3, 'Garbage Collection', 'Solid Waste Mgmt');
INSERT INTO categories VALUES (4, 'Street Lights', 'Electrical Dept');
INSERT INTO categories VALUES (5, 'Road & Potholes', 'Roads Dept');
INSERT INTO categories VALUES (6, 'Public Toilets', 'Sanitation Dept');
INSERT INTO priorities VALUES ('High', 2);
INSERT INTO priorities VALUES ('Medium', 5);
INSERT INTO priorities VALUES ('Low', 10);
INSERT INTO staging_complaints VALUES (1, 'GRV-2026-0001', '2026-07-01', 'W04', 'Garbage Collection', 'Medium', 'Resolved', 'D. Pawar', '2026-07-05');
INSERT INTO staging_complaints VALUES (2, 'GRV-2026-0002', '2026-07-01', 'W05', 'Garbage Collection', 'Medium', 'Resolved', 'M. Shinde', '2026-07-08');
INSERT INTO staging_complaints VALUES (3, 'GRV-2026-0003', '2026-07-01', 'W02', 'Road & Potholes', 'High', 'Resolved', 'M. Shinde', '2026-07-02');
INSERT INTO staging_complaints VALUES (4, 'GRV-2026-0004', '2026-07-01', 'W05', 'Garbage Collection', 'Medium', 'Resolved', 'R. Patil', '2026-07-08');
INSERT INTO staging_complaints VALUES (5, 'GRV-2026-0005', '2026-07-02', 'W06', 'Public Toilets', 'Medium', 'Resolved', 'D. Pawar', '2026-07-09');
INSERT INTO staging_complaints VALUES (6, 'GRV-2026-0006', '2026-07-02', 'W07', 'Water Supply', 'Low', 'Resolved', 'M. Shinde', '2026-07-07');
INSERT INTO staging_complaints VALUES (7, 'GRV-2026-0007', '2026-07-03', 'W07', 'Water Supply', 'Medium', 'Resolved', 'V. More', '2026-07-06');
INSERT INTO staging_complaints VALUES (8, 'GRV-2026-0008', '2026-07-03', 'W06', 'Water Supply', 'Medium', 'Resolved', 'A. Kulkarni', '2026-07-07');
INSERT INTO staging_complaints VALUES (9, 'GRV-2026-0009', '2026-07-03', 'W05', 'Garbage Collection', 'Medium', 'Resolved', 'M. Shinde', '2026-07-05');
INSERT INTO staging_complaints VALUES (10, 'GRV-2026-0010', '2026-07-03', 'W05', 'Public Toilets', 'High', 'Resolved', 'R. Patil', '2026-07-06');
INSERT INTO staging_complaints VALUES (11, 'GRV-2026-0011', '2026-07-04', 'W07', 'Drainage & Sewage', 'High', 'Resolved', 'P. Jadhav', '2026-07-06');
INSERT INTO staging_complaints VALUES (12, 'GRV-2026-0012', '2026-07-04', 'W08', 'Garbage Collection', 'Medium', 'Resolved', 'A. Kulkarni', '2026-07-06');
INSERT INTO staging_complaints VALUES (13, 'GRV-2026-0013', '2026-07-04', 'W02', 'Road & Potholes', 'High', 'Resolved', 'S. Deshmukh', '2026-07-05');
INSERT INTO staging_complaints VALUES (14, 'GRV-2026-0014', '2026-07-04', 'W04', 'Road & Potholes', 'High', 'Resolved', 'D. Pawar', '2026-07-07');
INSERT INTO staging_complaints VALUES (15, 'GRV-2026-0015', '2026-07-04', 'W07', 'Water Supply', 'Low', 'Resolved', 'R. Patil', '2026-07-10');
INSERT INTO staging_complaints VALUES (16, 'GRV-2026-0016', '2026-07-04', 'W02', 'Water Supply', 'Low', 'In Progress', 'R. Patil', NULL);
INSERT INTO staging_complaints VALUES (17, 'GRV-2026-0017', '2026-07-04', 'W05', 'Water Supply', 'Medium', 'Resolved', 'D. Pawar', '2026-07-07');
INSERT INTO staging_complaints VALUES (18, 'GRV-2026-0018', '2026-07-05', 'W06', 'Garbage Collection', 'High', 'Resolved', 'A. Kulkarni', '2026-07-08');
INSERT INTO staging_complaints VALUES (19, 'GRV-2026-0019', '2026-07-06', 'W04', 'Water Supply', 'Low', 'Resolved', 'D. Pawar', '2026-07-12');
INSERT INTO staging_complaints VALUES (20, 'GRV-2026-0020', '2026-07-06', 'W07', 'Water Supply', 'Low', 'Resolved', 'N. Kale', '2026-07-15');
INSERT INTO staging_complaints VALUES (21, 'GRV-2026-0021', '2026-07-06', 'W04', 'Public Toilets', 'Medium', 'In Progress', 'R. Patil', NULL);
INSERT INTO staging_complaints VALUES (22, 'GRV-2026-0022', '2026-07-07', 'W01', 'Garbage Collection', 'Medium', 'Resolved', 'P. Jadhav', '2026-07-09');
INSERT INTO staging_complaints VALUES (23, 'GRV-2026-0023', '2026-07-07', 'W07', 'Garbage Collection', 'High', 'Resolved', 'P. Jadhav', NULL);
INSERT INTO staging_complaints VALUES (24, 'GRV-2026-0024', '2026-07-07', 'W01', 'Garbage Collection', 'Medium', 'Resolved', 'D. Pawar', '2026-07-09');
INSERT INTO staging_complaints VALUES (25, 'GRV-2026-0025', '2026-07-07', 'W06', 'Water Supply', 'Medium', 'In Progress', 'M. Shinde', NULL);
INSERT INTO staging_complaints VALUES (26, 'GRV-2026-0026', '2026-07-08', 'W04', 'Water Supply', 'Low', 'Resolved', 'N. Kale', '2026-07-11');
INSERT INTO staging_complaints VALUES (27, 'GRV-2026-0027', '2026-07-08', 'W04', 'Water Supply', 'Medium', 'Resolved', 'S. Deshmukh', '2026-07-14');
INSERT INTO staging_complaints VALUES (28, 'GRV-2026-0028', '2026-07-08', 'W07', 'Drainage & Sewage', 'High', 'Resolved', 'P. Jadhav', '2026-07-10');
INSERT INTO staging_complaints VALUES (29, 'GRV-2026-0029', '2026-07-08', 'W03', 'Drainage & Sewage', 'Medium', 'Resolved', 'N. Kale', '2026-07-14');
INSERT INTO staging_complaints VALUES (30, 'GRV-2026-0030', '2026-07-08', 'W08', 'Road & Potholes', 'Low', 'Resolved', 'R. Patil', '2026-07-19');
INSERT INTO staging_complaints VALUES (31, 'GRV-2026-0031', '2026-07-08', 'W07', 'Water Supply', 'Low', 'Resolved', 'R. Patil', '2026-07-20');
INSERT INTO staging_complaints VALUES (32, 'GRV-2026-0032', '2026-07-08', 'W01', 'Road & Potholes', 'Low', 'Resolved', 'M. Shinde', '2026-07-18');
INSERT INTO staging_complaints VALUES (33, 'GRV-2026-0033', '2026-07-08', 'W06', 'Water Supply', 'High', 'In Progress', 'D. Pawar', NULL);
INSERT INTO staging_complaints VALUES (34, 'GRV-2026-0034', '2026-07-08', 'W04', 'Garbage Collection', 'Medium', 'Resolved', 'S. Deshmukh', '2026-07-10');
INSERT INTO staging_complaints VALUES (35, 'GRV-2026-0035', '2026-07-08', 'W02', 'Street Lights', 'Medium', 'Resolved', 'D. Pawar', '2026-07-10');
INSERT INTO staging_complaints VALUES (36, 'GRV-2026-0036', '2026-07-09', 'W05', 'Drainage & Sewage', 'High', 'Resolved', 'M. Shinde', '2026-07-11');
INSERT INTO staging_complaints VALUES (37, 'GRV-2026-0037', '2026-07-09', 'W08', 'Street Lights', 'Low', 'Resolved', 'P. Jadhav', '2026-07-13');
INSERT INTO staging_complaints VALUES (38, 'GRV-2026-0038', '2026-07-09', 'W04', 'Road & Potholes', 'Medium', 'Resolved', 'P. Jadhav', '2026-07-11');
INSERT INTO staging_complaints VALUES (39, 'GRV-2026-0039', '2026-07-09', 'W03', NULL, 'Medium', 'Resolved', 'P. Jadhav', '2026-07-11');
INSERT INTO staging_complaints VALUES (40, 'GRV-2026-0040', '2026-07-09', 'W04', 'Public Toilets', 'High', 'Resolved', 'P. Jadhav', '2026-07-10');
INSERT INTO staging_complaints VALUES (41, 'GRV-2026-0041', '2026-07-09', 'W02', 'Garbage Collection', 'Medium', 'In Progress', 'P. Jadhav', NULL);
INSERT INTO staging_complaints VALUES (42, 'GRV-2026-0042', '2026-07-10', 'W01', 'Public Toilets', 'Low', 'Resolved', 'D. Pawar', '2026-07-14');
INSERT INTO staging_complaints VALUES (43, 'GRV-2026-0043', '2026-07-10', 'W04', 'Public Toilets', 'Medium', 'Resolved', 'P. Jadhav', '2026-07-12');
INSERT INTO staging_complaints VALUES (44, 'GRV-2026-0044', '2026-07-10', 'W05', 'Public Toilets', 'High', 'Resolved', 'M. Shinde', '2026-07-12');
INSERT INTO staging_complaints VALUES (45, 'GRV-2026-0045', '2026-07-10', 'W07', 'Garbage Collection', 'Low', 'Resolved', 'D. Pawar', '2026-07-13');
INSERT INTO staging_complaints VALUES (46, 'GRV-2026-0046', '2026-07-11', 'W03', 'Street Lights', 'Medium', 'Resolved', 'S. Deshmukh', '2026-07-15');
INSERT INTO staging_complaints VALUES (47, 'GRV-2026-0047', '2026-07-11', 'W06', 'Road & Potholes', 'High', 'Resolved', 'M. Shinde', '2026-07-12');
INSERT INTO staging_complaints VALUES (48, 'GRV-2026-0048', '2026-07-11', 'W05', 'Street Lights', 'Low', 'Resolved', 'N. Kale', '2026-07-15');
INSERT INTO staging_complaints VALUES (49, 'GRV-2026-0049', '2026-07-11', 'W06', 'Public Toilets', 'Medium', 'Resolved', 'A. Kulkarni', '2026-07-17');
INSERT INTO staging_complaints VALUES (50, 'GRV-2026-0050', '2026-07-11', 'W05', 'Drainage & Sewage', 'High', 'Resolved', 'P. Jadhav', '2026-07-12');
INSERT INTO staging_complaints VALUES (51, 'GRV-2026-0051', '2026-07-11', 'W06', 'Garbage Collection', 'Medium', 'Resolved', 'A. Kulkarni', '2026-07-15');
INSERT INTO staging_complaints VALUES (52, 'GRV-2026-0052', '2026-07-11', 'W04', 'Road & Potholes', 'Medium', 'Resolved', 'N. Kale', '2026-07-13');
INSERT INTO staging_complaints VALUES (53, 'GRV-2026-0053', '2026-07-12', 'W05', 'Garbage Collection', 'Low', 'Resolved', 'R. Patil', '2026-07-25');
INSERT INTO staging_complaints VALUES (54, 'GRV-2026-0054', '2026-07-12', 'W05', 'Water Supply', 'Medium', 'Resolved', 'P. Jadhav', '2026-07-18');
INSERT INTO staging_complaints VALUES (55, 'GRV-2026-0055', '2026-07-12', 'W08', 'Garbage Collection', 'Medium', 'Resolved', 'R. Patil', '2026-07-16');
INSERT INTO staging_complaints VALUES (56, 'GRV-2026-0056', '2026-07-12', 'W08', 'Street Lights', 'High', 'Resolved', 'V. More', '2026-07-14');
INSERT INTO staging_complaints VALUES (57, 'GRV-2026-0057', '2026-07-12', 'W03', 'Public Toilets', 'Medium', 'Resolved', 'R. Patil', '2026-07-15');
INSERT INTO staging_complaints VALUES (58, 'GRV-2026-0058', '2026-07-13', 'W04', 'Drainage & Sewage', 'High', 'Resolved', 'M. Shinde', '2026-07-15');
INSERT INTO staging_complaints VALUES (59, 'GRV-2026-0059', '2026-07-13', 'W07', 'Road & Potholes', 'Low', 'Resolved', 'M. Shinde', '2026-07-25');
INSERT INTO staging_complaints VALUES (60, 'GRV-2026-0060', '2026-07-13', 'W01', 'Drainage & Sewage', 'Medium', 'Resolved', 'V. More', '2026-07-18');
INSERT INTO staging_complaints VALUES (61, 'GRV-2026-0061', '2026-07-13', 'W04', 'Water Supply', 'Medium', 'Resolved', 'N. Kale', '2026-07-20');
INSERT INTO staging_complaints VALUES (62, 'GRV-2026-0062', '2026-07-14', 'W05', 'Garbage Collection', 'Medium', 'Resolved', 'A. Kulkarni', '2026-07-21');
INSERT INTO staging_complaints VALUES (63, 'GRV-2026-0063', '2026-07-14', 'W08', 'Water Supply', 'Medium', 'In Progress', 'S. Deshmukh', NULL);
INSERT INTO staging_complaints VALUES (64, 'GRV-2026-0064', '2026-07-14', 'W08', 'Garbage Collection', 'Low', 'In Progress', 'S. Deshmukh', NULL);
INSERT INTO staging_complaints VALUES (65, 'GRV-2026-0065', '2026-07-14', 'W02', 'Drainage & Sewage', 'High', 'Resolved', 'D. Pawar', '2026-07-16');
INSERT INTO staging_complaints VALUES (66, 'GRV-2026-0066', '2026-07-14', 'W01', 'Water Supply', 'Low', 'Resolved', 'A. Kulkarni', '2026-07-20');
INSERT INTO staging_complaints VALUES (67, 'GRV-2026-0067', '2026-07-14', 'W03', 'Street Lights', 'Medium', 'Resolved', 'N. Kale', '2026-07-19');
INSERT INTO staging_complaints VALUES (68, 'GRV-2026-0068', '2026-07-14', 'W02', 'Street Lights', 'High', 'Resolved', 'M. Shinde', '2026-07-12');
INSERT INTO staging_complaints VALUES (69, 'GRV-2026-0069', '2026-07-15', 'W01', 'Garbage Collection', 'Medium', 'Resolved', 'D. Pawar', '2026-07-18');
INSERT INTO staging_complaints VALUES (70, 'GRV-2026-0070', '2026-07-15', 'W04', 'Drainage & Sewage', 'Medium', 'Resolved', 'M. Shinde', '2026-07-18');
INSERT INTO staging_complaints VALUES (71, 'GRV-2026-0071', '2026-07-15', 'W05', 'Water Supply', 'Medium', 'Resolved', 'N. Kale', '2026-07-18');
INSERT INTO staging_complaints VALUES (72, 'GRV-2026-0072', '2026-07-16', 'W07', 'Water Supply', 'Medium', 'Resolved', 'A. Kulkarni', '2026-07-19');
INSERT INTO staging_complaints VALUES (73, 'GRV-2026-0073', '2026-07-16', 'W06', 'Street Lights', 'Low', 'Resolved', 'P. Jadhav', '2026-07-21');
INSERT INTO staging_complaints VALUES (74, 'GRV-2026-0074', '2026-07-16', 'W04', 'Street Lights', 'Medium', 'Resolved', 'M. Shinde', '2026-07-19');
INSERT INTO staging_complaints VALUES (75, 'GRV-2026-0075', '2026-07-16', 'W05', 'Drainage & Sewage', 'Medium', 'Resolved', 'R. Patil', '2026-07-21');
INSERT INTO staging_complaints VALUES (76, 'GRV-2026-0076', '2026-07-16', 'W01', 'Road & Potholes', 'Medium', 'Resolved', 'N. Kale', '2026-07-18');
INSERT INTO staging_complaints VALUES (77, 'GRV-2026-0077', '2026-07-16', 'W03', 'Water Supply', 'High', 'Resolved', 'R. Patil', '2026-07-18');
INSERT INTO staging_complaints VALUES (78, 'GRV-2026-0078', '2026-07-17', 'W06', 'Garbage Collection', 'Low', 'Resolved', 'R. Patil', '2026-07-31');
INSERT INTO staging_complaints VALUES (79, 'GRV-2026-0079', '2026-07-17', 'W08', 'Drainage & Sewage', 'High', 'Resolved', 'N. Kale', '2026-07-19');
INSERT INTO staging_complaints VALUES (80, 'GRV-2026-0080', '2026-07-17', 'W08', 'Road & Potholes', 'Low', 'Resolved', 'P. Jadhav', '2026-07-20');
INSERT INTO staging_complaints VALUES (81, 'GRV-2026-0081', '2026-07-17', 'W02', 'Water Supply', 'Medium', 'Resolved', 'N. Kale', '2026-07-23');
INSERT INTO staging_complaints VALUES (82, 'GRV-2026-0082', '2026-07-17', 'W07', 'Drainage & Sewage', 'Low', 'Resolved', 'M. Shinde', '2026-07-28');
INSERT INTO staging_complaints VALUES (83, 'GRV-2026-0083', '2026-07-17', 'W04', 'Drainage & Sewage', 'Low', 'Resolved', 'D. Pawar', '2026-07-28');
INSERT INTO staging_complaints VALUES (84, 'GRV-2026-0084', '2026-07-18', 'W07', 'Water Supply', 'Medium', 'Resolved', 'S. Deshmukh', '2026-07-20');
INSERT INTO staging_complaints VALUES (85, 'GRV-2026-0085', '2026-07-18', 'W04', 'Road & Potholes', 'High', 'Resolved', 'V. More', '2026-07-21');
INSERT INTO staging_complaints VALUES (86, 'GRV-2026-0086', '2026-07-18', 'W01', 'Drainage & Sewage', 'Medium', 'Resolved', 'V. More', '2026-07-24');
INSERT INTO staging_complaints VALUES (87, 'GRV-2026-0087', '2026-07-19', 'W02', 'Public Toilets', 'Medium', 'Resolved', 'D. Pawar', NULL);
INSERT INTO staging_complaints VALUES (88, 'GRV-2026-0088', '2026-07-19', 'W07', 'Street Lights', 'Medium', 'Resolved', 'D. Pawar', '2026-07-26');
INSERT INTO staging_complaints VALUES (89, 'GRV-2026-0089', '2026-07-19', 'W01', 'Water Supply', 'Medium', 'Resolved', 'R. Patil', '2026-07-25');
INSERT INTO staging_complaints VALUES (90, 'GRV-2026-0090', '2026-07-19', 'W06', 'Garbage Collection', 'Medium', 'Resolved', 'S. Deshmukh', '2026-07-25');
INSERT INTO staging_complaints VALUES (91, 'GRV-2026-0091', '2026-07-19', 'W03', 'Garbage Collection', 'Medium', 'Resolved', 'A. Kulkarni', '2026-07-21');
INSERT INTO staging_complaints VALUES (92, 'GRV-2026-0092', '2026-07-19', 'W03', 'Garbage Collection', 'Medium', 'Open', NULL, NULL);
INSERT INTO staging_complaints VALUES (93, 'GRV-2026-0093', '2026-07-20', 'W02', 'Drainage & Sewage', 'High', 'Resolved', 'D. Pawar', '2026-07-23');
INSERT INTO staging_complaints VALUES (94, 'GRV-2026-0094', '2026-07-20', 'W08', 'Water Supply', 'High', 'Resolved', 'S. Deshmukh', '2026-07-22');
INSERT INTO staging_complaints VALUES (95, 'GRV-2026-0095', '2026-07-20', 'W05', 'Road & Potholes', 'Medium', 'Resolved', 'P. Jadhav', '2026-07-24');
INSERT INTO staging_complaints VALUES (96, 'GRV-2026-0096', '2026-07-20', 'W04', 'Water Supply', 'Medium', 'Resolved', 'M. Shinde', '2026-07-23');
INSERT INTO staging_complaints VALUES (97, 'GRV-2026-0097', '2026-07-20', 'W04', 'Drainage & Sewage', 'Medium', 'Resolved', 'S. Deshmukh', '2026-07-23');
INSERT INTO staging_complaints VALUES (98, 'GRV-2026-0098', '2026-07-20', 'W02', 'Street Lights', 'Low', 'Resolved', 'M. Shinde', '2026-08-02');
INSERT INTO staging_complaints VALUES (99, 'GRV-2026-0099', '2026-07-20', 'W01', 'Road & Potholes', 'Low', 'Resolved', 'A. Kulkarni', '2026-07-26');
INSERT INTO staging_complaints VALUES (100, 'GRV-2026-0100', '2026-07-20', 'W04', 'Water Supply', 'Low', 'Resolved', 'R. Patil', '2026-07-27');
INSERT INTO staging_complaints VALUES (101, 'GRV-2026-0101', '2026-07-20', 'W01', 'Garbage Collection', 'Medium', 'Resolved', 'V. More', '2026-07-25');
INSERT INTO staging_complaints VALUES (102, 'GRV-2026-0102', '2026-07-20', 'W03', 'Water Supply', 'Medium', 'Resolved', 'A. Kulkarni', '2026-07-27');
INSERT INTO staging_complaints VALUES (103, 'GRV-2026-0103', '2026-07-21', 'W04', 'Garbage Collection', 'Medium', 'Resolved', 'N. Kale', '2026-07-27');
INSERT INTO staging_complaints VALUES (104, 'GRV-2026-0104', '2026-07-21', 'W05', 'Street Lights', 'High', 'Resolved', 'D. Pawar', '2026-07-22');
INSERT INTO staging_complaints VALUES (105, 'GRV-2026-0105', '2026-07-21', 'W02', 'Garbage Collection', 'High', 'Resolved', 'R. Patil', '2026-07-23');
INSERT INTO staging_complaints VALUES (106, 'GRV-2026-0106', '2026-07-22', 'W03', 'Street Lights', 'High', 'Resolved', 'P. Jadhav', '2026-07-23');
INSERT INTO staging_complaints VALUES (107, 'GRV-2026-0107', '2026-07-22', 'W01', 'Street Lights', 'Medium', 'Resolved', 'V. More', '2026-07-27');
INSERT INTO staging_complaints VALUES (108, 'GRV-2026-0108', '2026-07-22', 'W06', 'Garbage Collection', 'High', 'Resolved', 'N. Kale', '2026-07-23');
INSERT INTO staging_complaints VALUES (109, 'GRV-2026-0109', '2026-07-22', 'W03', 'Water Supply', 'High', 'Resolved', 'N. Kale', NULL);
INSERT INTO staging_complaints VALUES (110, 'GRV-2026-0110', '2026-07-22', 'W03', 'Garbage Collection', 'Medium', 'Resolved', 'R. Patil', '2026-07-24');
INSERT INTO staging_complaints VALUES (111, 'GRV-2026-0111', '2026-07-23', 'W02', 'Street Lights', 'Low', 'Resolved', 'R. Patil', '2026-07-21');
INSERT INTO staging_complaints VALUES (112, 'GRV-2026-0112', '2026-07-23', 'W03', 'Water Supply', 'Medium', 'Resolved', 'D. Pawar', '2026-07-25');
INSERT INTO staging_complaints VALUES (113, 'GRV-2026-0113', '2026-07-23', 'W04', 'Street Lights', 'Low', 'Resolved', 'A. Kulkarni', '2026-08-05');
INSERT INTO staging_complaints VALUES (114, 'GRV-2026-0114', '2026-07-24', 'W01', 'Public Toilets', 'Medium', 'Resolved', 'S. Deshmukh', '2026-07-29');
INSERT INTO staging_complaints VALUES (115, 'GRV-2026-0115', '2026-07-24', 'W03', 'Road & Potholes', 'Medium', 'Resolved', 'N. Kale', '2026-07-30');
INSERT INTO staging_complaints VALUES (116, 'GRV-2026-0116', '2026-07-24', 'W08', 'Garbage Collection', 'High', 'Resolved', 'N. Kale', '2026-07-25');
INSERT INTO staging_complaints VALUES (117, 'GRV-2026-0117', '2026-07-24', 'W06', 'Public Toilets', 'High', 'Resolved', 'M. Shinde', '2026-07-25');
INSERT INTO staging_complaints VALUES (118, 'GRV-2026-0118', '2026-07-25', NULL, 'Water Supply', 'Medium', 'Resolved', 'N. Kale', '2026-07-28');
INSERT INTO staging_complaints VALUES (119, 'GRV-2026-0119', '2026-07-25', 'W05', 'Garbage Collection', 'Medium', 'Resolved', 'M. Shinde', '2026-07-28');
INSERT INTO staging_complaints VALUES (120, 'GRV-2026-0120', '2026-07-25', 'W08', 'Garbage Collection', 'Medium', 'Resolved', 'A. Kulkarni', '2026-07-28');
INSERT INTO staging_complaints VALUES (121, 'GRV-2026-0121', '2026-07-25', 'W04', 'Garbage Collection', 'Medium', 'Resolved', 'D. Pawar', '2026-07-30');
INSERT INTO staging_complaints VALUES (122, 'GRV-2026-0122', '2026-07-25', 'W07', 'Road & Potholes', 'Low', 'Resolved', 'N. Kale', '2026-07-29');
INSERT INTO staging_complaints VALUES (123, 'GRV-2026-0123', '2026-07-25', 'W01', 'Drainage & Sewage', 'Low', 'Resolved', 'V. More', '2026-07-29');
INSERT INTO staging_complaints VALUES (124, 'GRV-2026-0124', '2026-07-26', 'W01', 'Road & Potholes', 'Medium', 'Resolved', 'R. Patil', '2026-08-02');
INSERT INTO staging_complaints VALUES (125, 'GRV-2026-0125', '2026-07-26', 'W02', 'Water Supply', 'High', 'Resolved', 'D. Pawar', '2026-07-29');
INSERT INTO staging_complaints VALUES (126, 'GRV-2026-0126', '2026-07-26', 'W03', 'Drainage & Sewage', 'Low', 'Resolved', 'M. Shinde', '2026-08-06');
INSERT INTO staging_complaints VALUES (127, 'GRV-2026-0127', '2026-07-27', 'W05', 'Water Supply', 'Medium', 'Resolved', 'P. Jadhav', '2026-08-03');
INSERT INTO staging_complaints VALUES (128, 'GRV-2026-0128', '2026-07-27', 'W05', 'Road & Potholes', 'Medium', 'Resolved', 'M. Shinde', '2026-08-03');
INSERT INTO staging_complaints VALUES (129, 'GRV-2026-0129', '2026-07-27', 'W04', 'Garbage Collection', 'Medium', 'Resolved', 'R. Patil', '2026-07-29');
INSERT INTO staging_complaints VALUES (130, 'GRV-2026-0130', '2026-07-27', 'W05', 'Garbage Collection', 'Medium', 'Resolved', 'R. Patil', '2026-08-03');
INSERT INTO staging_complaints VALUES (131, 'GRV-2026-0131', '2026-07-27', 'W01', 'Road & Potholes', 'Medium', 'Resolved', 'D. Pawar', '2026-07-31');
INSERT INTO staging_complaints VALUES (132, 'GRV-2026-0132', '2026-07-28', 'W02', 'Garbage Collection', 'Medium', 'Resolved', 'N. Kale', '2026-08-02');
INSERT INTO staging_complaints VALUES (133, 'GRV-2026-0133', '2026-07-28', 'W07', 'Street Lights', 'Medium', 'In Progress', 'V. More', NULL);
INSERT INTO staging_complaints VALUES (134, 'GRV-2026-0134', '2026-07-28', 'W04', 'Drainage & Sewage', 'High', 'Resolved', 'A. Kulkarni', '2026-07-30');
INSERT INTO staging_complaints VALUES (135, 'GRV-2026-0135', '2026-07-28', 'W05', 'Drainage & Sewage', 'Medium', 'Resolved', 'V. More', '2026-08-04');
INSERT INTO staging_complaints VALUES (136, 'GRV-2026-0136', '2026-07-29', 'W04', 'Street Lights', 'Low', 'Resolved', 'N. Kale', '2026-08-08');
INSERT INTO staging_complaints VALUES (137, 'GRV-2026-0137', '2026-07-29', 'W01', 'Garbage Collection', 'Medium', 'Resolved', 'A. Kulkarni', '2026-08-01');
INSERT INTO staging_complaints VALUES (138, 'GRV-2026-0138', '2026-07-29', 'W06', 'Water Supply', 'High', 'Resolved', 'M. Shinde', '2026-07-31');
INSERT INTO staging_complaints VALUES (139, 'GRV-2026-0139', '2026-07-29', 'W03', 'Garbage Collection', 'Medium', 'Resolved', 'D. Pawar', '2026-08-03');
INSERT INTO staging_complaints VALUES (140, 'GRV-2026-0140', '2026-07-29', 'W04', 'Water Supply', 'High', 'Resolved', 'S. Deshmukh', '2026-07-31');
INSERT INTO staging_complaints VALUES (141, 'GRV-2026-0141', '2026-07-30', 'W05', 'Street Lights', 'Low', 'Resolved', 'A. Kulkarni', '2026-08-05');
INSERT INTO staging_complaints VALUES (142, 'GRV-2026-0142', '2026-07-30', 'W06', 'Water Supply', 'Low', 'Resolved', 'D. Pawar', '2026-08-09');
INSERT INTO staging_complaints VALUES (143, 'GRV-2026-0143', '2026-07-30', 'W01', 'Drainage & Sewage', 'Low', 'Resolved', 'R. Patil', '2026-08-02');
INSERT INTO staging_complaints VALUES (144, 'GRV-2026-0144', '2026-07-30', 'W02', 'Drainage & Sewage', 'High', 'Resolved', 'M. Shinde', '2026-08-01');
INSERT INTO staging_complaints VALUES (145, 'GRV-2026-0145', '2026-07-30', 'W07', 'Water Supply', 'High', 'Resolved', 'P. Jadhav', '2026-07-31');
INSERT INTO staging_complaints VALUES (146, 'GRV-2026-0146', '2026-07-31', 'W08', 'Water Supply', 'Medium', 'Resolved', 'N. Kale', '2026-08-02');
INSERT INTO staging_complaints VALUES (147, 'GRV-2026-0147', '2026-07-31', 'W08', 'Street Lights', 'Medium', 'Resolved', 'P. Jadhav', '2026-08-07');
INSERT INTO staging_complaints VALUES (148, 'GRV-2026-0148', '2026-07-31', 'W06', 'Drainage & Sewage', 'High', 'Resolved', 'P. Jadhav', '2026-08-03');
INSERT INTO staging_complaints VALUES (149, 'GRV-2026-0149', '2026-08-01', 'W07', 'Street Lights', 'Medium', 'Resolved', 'P. Jadhav', '2026-08-08');
INSERT INTO staging_complaints VALUES (150, 'GRV-2026-0150', '2026-08-01', 'W04', 'Drainage & Sewage', 'Low', 'Resolved', 'R. Patil', '2026-08-10');
INSERT INTO staging_complaints VALUES (151, 'GRV-2026-0151', '2026-08-01', 'W04', 'Drainage & Sewage', 'Medium', 'Open', 'N. Kale', NULL);
INSERT INTO staging_complaints VALUES (152, 'GRV-2026-0152', '2026-08-01', 'W08', 'Drainage & Sewage', 'Medium', 'Resolved', 'A. Kulkarni', '2026-08-06');
INSERT INTO staging_complaints VALUES (153, 'GRV-2026-0153', '2026-08-02', 'W04', 'Road & Potholes', 'Medium', 'Resolved', 'M. Shinde', '2026-08-05');
INSERT INTO staging_complaints VALUES (154, 'GRV-2026-0154', '2026-08-02', 'W03', 'Garbage Collection', 'Medium', 'Resolved', 'S. Deshmukh', '2026-08-04');
INSERT INTO staging_complaints VALUES (155, 'GRV-2026-0155', '2026-08-03', 'W03', 'Street Lights', 'High', 'Resolved', 'R. Patil', '2026-08-04');
INSERT INTO staging_complaints VALUES (156, 'GRV-2026-0156', '2026-08-03', 'W02', 'Street Lights', 'Medium', 'Resolved', 'V. More', '2026-08-05');
INSERT INTO staging_complaints VALUES (157, 'GRV-2026-0157', '2026-08-03', 'W02', 'Water Supply', 'Low', 'Resolved', 'N. Kale', '2026-08-15');
INSERT INTO staging_complaints VALUES (158, 'GRV-2026-0158', '2026-08-03', 'W02', 'Water Supply', 'Medium', 'Resolved', 'S. Deshmukh', '2026-08-10');
INSERT INTO staging_complaints VALUES (159, 'GRV-2026-0159', '2026-08-03', 'W05', 'Road & Potholes', 'Medium', 'Resolved', 'M. Shinde', '2026-08-05');
INSERT INTO staging_complaints VALUES (160, 'GRV-2026-0160', '2026-08-04', 'W05', 'Drainage & Sewage', 'Medium', 'Resolved', 'P. Jadhav', '2026-08-02');
INSERT INTO staging_complaints VALUES (161, 'GRV-2026-0161', '2026-08-05', 'W06', 'Water Supply', 'Low', 'Resolved', 'D. Pawar', '2026-08-15');
INSERT INTO staging_complaints VALUES (162, 'GRV-2026-0162', '2026-08-05', 'W01', 'Road & Potholes', 'Medium', 'Resolved', 'S. Deshmukh', '2026-08-07');
INSERT INTO staging_complaints VALUES (163, 'GRV-2026-0163', '2026-08-05', 'W04', 'Drainage & Sewage', 'Low', 'Resolved', 'P. Jadhav', '2026-08-18');
INSERT INTO staging_complaints VALUES (164, 'GRV-2026-0164', '2026-08-05', 'W04', 'Water Supply', 'High', 'Resolved', 'A. Kulkarni', '2026-08-07');
INSERT INTO staging_complaints VALUES (165, 'GRV-2026-0165', '2026-08-06', 'W08', 'Water Supply', 'Medium', 'Resolved', 'D. Pawar', '2026-08-12');
INSERT INTO staging_complaints VALUES (166, 'GRV-2026-0166', '2026-08-06', 'W05', 'Garbage Collection', 'Low', 'Resolved', 'M. Shinde', '2026-08-11');
INSERT INTO staging_complaints VALUES (167, 'GRV-2026-0167', '2026-08-06', 'W03', 'Public Toilets', 'Medium', 'Resolved', 'S. Deshmukh', '2026-08-11');
INSERT INTO staging_complaints VALUES (168, 'GRV-2026-0168', '2026-08-06', 'W02', 'Garbage Collection', 'Low', 'Resolved', 'N. Kale', '2026-08-13');
INSERT INTO staging_complaints VALUES (169, 'GRV-2026-0169', '2026-08-07', 'W02', NULL, 'Low', 'Resolved', 'V. More', '2026-08-17');
INSERT INTO staging_complaints VALUES (170, 'GRV-2026-0170', '2026-08-07', 'W03', 'Water Supply', 'Medium', 'Resolved', 'M. Shinde', '2026-08-14');
INSERT INTO staging_complaints VALUES (171, 'GRV-2026-0171', '2026-08-08', 'W01', 'Public Toilets', 'High', 'Resolved', 'R. Patil', '2026-08-09');
INSERT INTO staging_complaints VALUES (172, 'GRV-2026-0172', '2026-08-08', 'W06', 'Road & Potholes', 'Medium', 'Resolved', 'P. Jadhav', '2026-08-12');
INSERT INTO staging_complaints VALUES (173, 'GRV-2026-0173', '2026-08-08', 'W08', 'Garbage Collection', 'High', 'Resolved', 'M. Shinde', '2026-08-10');
INSERT INTO staging_complaints VALUES (174, 'GRV-2026-0174', '2026-08-09', 'W03', 'Drainage & Sewage', 'Low', 'Resolved', 'V. More', '2026-08-23');
INSERT INTO staging_complaints VALUES (175, 'GRV-2026-0175', '2026-08-09', 'W04', 'Garbage Collection', 'Medium', 'Resolved', 'S. Deshmukh', '2026-08-12');
INSERT INTO staging_complaints VALUES (176, 'GRV-2026-0176', '2026-08-09', 'W04', 'Water Supply', 'Medium', 'Resolved', 'P. Jadhav', '2026-08-16');
INSERT INTO staging_complaints VALUES (177, 'GRV-2026-0177', '2026-08-10', 'W04', 'Street Lights', 'Medium', 'Resolved', 'P. Jadhav', '2026-08-17');
INSERT INTO staging_complaints VALUES (178, 'GRV-2026-0178', '2026-08-10', 'W01', 'Water Supply', 'Medium', 'Resolved', 'N. Kale', '2026-08-16');
INSERT INTO staging_complaints VALUES (179, 'GRV-2026-0179', '2026-08-10', 'W05', 'Street Lights', 'Medium', 'Resolved', 'N. Kale', '2026-08-12');
INSERT INTO staging_complaints VALUES (180, 'GRV-2026-0180', '2026-08-11', 'W07', 'Water Supply', 'Medium', 'Resolved', 'N. Kale', '2026-08-16');
INSERT INTO staging_complaints VALUES (181, 'GRV-2026-0181', '2026-08-11', 'W04', 'Road & Potholes', 'Medium', 'Resolved', 'D. Pawar', '2026-08-16');
INSERT INTO staging_complaints VALUES (182, 'GRV-2026-0182', '2026-08-11', 'W02', 'Garbage Collection', 'Medium', 'In Progress', 'N. Kale', NULL);
INSERT INTO staging_complaints VALUES (183, 'GRV-2026-0183', '2026-08-12', 'W05', 'Street Lights', 'Medium', 'In Progress', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (184, 'GRV-2026-0184', '2026-08-12', 'W03', 'Street Lights', 'Medium', 'In Progress', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (185, 'GRV-2026-0185', '2026-08-13', 'W02', NULL, 'Medium', 'Resolved', 'R. Patil', '2026-08-18');
INSERT INTO staging_complaints VALUES (186, 'GRV-2026-0186', '2026-08-13', 'W04', 'Street Lights', 'Low', 'Resolved', 'D. Pawar', '2026-08-17');
INSERT INTO staging_complaints VALUES (187, 'GRV-2026-0187', '2026-08-13', 'W01', 'Garbage Collection', 'Low', 'Resolved', 'V. More', '2026-08-26');
INSERT INTO staging_complaints VALUES (188, 'GRV-2026-0188', '2026-08-13', 'W04', 'Garbage Collection', 'Low', 'In Progress', 'S. Deshmukh', NULL);
INSERT INTO staging_complaints VALUES (189, 'GRV-2026-0189', '2026-08-13', 'W01', 'Street Lights', 'Medium', 'Resolved', 'A. Kulkarni', '2026-08-17');
INSERT INTO staging_complaints VALUES (190, 'GRV-2026-0190', '2026-08-13', 'W07', 'Water Supply', 'Medium', 'Resolved', 'P. Jadhav', '2026-08-18');
INSERT INTO staging_complaints VALUES (191, 'GRV-2026-0191', '2026-08-14', 'W07', 'Water Supply', 'Medium', 'In Progress', 'M. Shinde', NULL);
INSERT INTO staging_complaints VALUES (192, 'GRV-2026-0192', '2026-08-14', 'W08', 'Public Toilets', 'Low', 'Resolved', 'S. Deshmukh', '2026-08-18');
INSERT INTO staging_complaints VALUES (193, 'GRV-2026-0193', '2026-08-14', 'W08', 'Road & Potholes', 'Medium', 'Resolved', 'R. Patil', '2026-08-20');
INSERT INTO staging_complaints VALUES (194, 'GRV-2026-0194', '2026-08-14', 'W07', 'Drainage & Sewage', 'Medium', 'Resolved', 'R. Patil', '2026-08-17');
INSERT INTO staging_complaints VALUES (195, 'GRV-2026-0195', '2026-08-14', 'W04', 'Road & Potholes', 'Medium', 'Resolved', 'P. Jadhav', '2026-08-18');
INSERT INTO staging_complaints VALUES (196, 'GRV-2026-0196', '2026-08-14', 'W08', 'Public Toilets', 'Medium', 'Resolved', 'P. Jadhav', '2026-08-20');
INSERT INTO staging_complaints VALUES (197, 'GRV-2026-0197', '2026-08-14', 'W06', 'Drainage & Sewage', 'Medium', 'Resolved', 'S. Deshmukh', '2026-08-18');
INSERT INTO staging_complaints VALUES (198, 'GRV-2026-0198', '2026-08-15', 'W05', 'Street Lights', 'Medium', 'In Progress', 'V. More', NULL);
INSERT INTO staging_complaints VALUES (199, 'GRV-2026-0199', '2026-08-15', 'W06', 'Road & Potholes', 'High', 'Resolved', 'A. Kulkarni', '2026-08-16');
INSERT INTO staging_complaints VALUES (200, 'GRV-2026-0200', '2026-08-15', 'W05', 'Water Supply', 'High', 'Resolved', 'R. Patil', '2026-08-16');
INSERT INTO staging_complaints VALUES (201, 'GRV-2026-0201', '2026-08-15', 'W08', 'Road & Potholes', 'High', 'Resolved', 'N. Kale', '2026-08-16');
INSERT INTO staging_complaints VALUES (202, 'GRV-2026-0202', '2026-08-15', NULL, 'Road & Potholes', 'High', 'Resolved', 'P. Jadhav', '2026-08-18');
INSERT INTO staging_complaints VALUES (203, 'GRV-2026-0203', '2026-08-16', 'W02', 'Water Supply', 'Medium', 'Resolved', 'S. Deshmukh', '2026-08-20');
INSERT INTO staging_complaints VALUES (204, 'GRV-2026-0204', '2026-08-16', 'W04', 'Garbage Collection', 'Medium', 'In Progress', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (205, 'GRV-2026-0205', '2026-08-16', 'W08', 'Garbage Collection', 'Low', 'Resolved', 'A. Kulkarni', '2026-08-21');
INSERT INTO staging_complaints VALUES (206, 'GRV-2026-0206', '2026-08-16', 'W08', 'Water Supply', 'Medium', 'Resolved', 'V. More', '2026-08-22');
INSERT INTO staging_complaints VALUES (207, 'GRV-2026-0207', '2026-08-16', 'W02', 'Garbage Collection', 'Low', 'Resolved', 'A. Kulkarni', '2026-08-23');
INSERT INTO staging_complaints VALUES (208, 'GRV-2026-0208', '2026-08-16', 'W06', 'Water Supply', 'High', 'In Progress', 'D. Pawar', NULL);
INSERT INTO staging_complaints VALUES (209, 'GRV-2026-0209', '2026-08-16', 'W01', 'Garbage Collection', 'Low', 'Resolved', 'R. Patil', '2026-08-24');
INSERT INTO staging_complaints VALUES (210, 'GRV-2026-0210', '2026-08-17', 'W06', 'Drainage & Sewage', 'Low', 'Resolved', 'M. Shinde', '2026-08-29');
INSERT INTO staging_complaints VALUES (211, 'GRV-2026-0211', '2026-08-17', 'W05', 'Drainage & Sewage', 'Medium', 'Resolved', 'P. Jadhav', '2026-08-23');
INSERT INTO staging_complaints VALUES (212, 'GRV-2026-0212', '2026-08-18', 'W06', 'Drainage & Sewage', 'Medium', 'Resolved', 'V. More', '2026-08-21');
INSERT INTO staging_complaints VALUES (213, 'GRV-2026-0213', '2026-08-18', 'W02', 'Public Toilets', 'Medium', 'Resolved', 'P. Jadhav', '2026-08-21');
INSERT INTO staging_complaints VALUES (214, 'GRV-2026-0214', '2026-08-19', 'W02', 'Water Supply', 'Low', 'In Progress', 'N. Kale', NULL);
INSERT INTO staging_complaints VALUES (215, 'GRV-2026-0215', '2026-08-19', 'W05', 'Garbage Collection', 'High', 'Resolved', 'D. Pawar', '2026-08-20');
INSERT INTO staging_complaints VALUES (216, 'GRV-2026-0216', '2026-08-20', 'W07', 'Garbage Collection', 'Medium', 'Resolved', 'S. Deshmukh', '2026-08-25');
INSERT INTO staging_complaints VALUES (217, 'GRV-2026-0217', '2026-08-20', 'W08', 'Water Supply', 'Medium', 'Resolved', 'R. Patil', '2026-08-22');
INSERT INTO staging_complaints VALUES (218, 'GRV-2026-0218', '2026-08-20', 'W02', 'Road & Potholes', 'Medium', 'Open', 'R. Patil', NULL);
INSERT INTO staging_complaints VALUES (219, 'GRV-2026-0219', '2026-08-20', 'W05', 'Road & Potholes', 'Medium', 'In Progress', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (220, 'GRV-2026-0220', '2026-08-20', 'W01', 'Drainage & Sewage', 'Medium', 'Resolved', 'S. Deshmukh', '2026-08-25');
INSERT INTO staging_complaints VALUES (221, 'GRV-2026-0221', '2026-08-20', 'W07', 'Road & Potholes', 'Medium', 'Resolved', 'N. Kale', '2026-08-22');
INSERT INTO staging_complaints VALUES (222, 'GRV-2026-0222', '2026-08-20', 'W03', 'Garbage Collection', 'Low', 'Resolved', 'S. Deshmukh', '2026-08-28');
INSERT INTO staging_complaints VALUES (223, 'GRV-2026-0223', '2026-08-20', 'W03', 'Water Supply', 'Medium', 'Resolved', 'A. Kulkarni', '2026-08-24');
INSERT INTO staging_complaints VALUES (224, 'GRV-2026-0224', '2026-08-21', 'W02', 'Street Lights', 'High', 'Resolved', 'D. Pawar', '2026-08-22');
INSERT INTO staging_complaints VALUES (225, 'GRV-2026-0225', '2026-08-21', 'W04', 'Water Supply', 'Low', 'Resolved', 'A. Kulkarni', '2026-09-02');
INSERT INTO staging_complaints VALUES (226, 'GRV-2026-0226', '2026-08-21', 'W03', 'Drainage & Sewage', 'Low', 'In Progress', 'D. Pawar', NULL);
INSERT INTO staging_complaints VALUES (227, 'GRV-2026-0227', '2026-08-21', 'W05', 'Garbage Collection', 'Low', 'In Progress', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (228, 'GRV-2026-0228', '2026-08-21', 'W02', 'Water Supply', 'High', 'Resolved', 'R. Patil', '2026-08-22');
INSERT INTO staging_complaints VALUES (229, 'GRV-2026-0229', '2026-08-23', 'W01', 'Public Toilets', 'Low', 'Resolved', 'D. Pawar', '2026-09-06');
INSERT INTO staging_complaints VALUES (230, 'GRV-2026-0230', '2026-08-23', NULL, 'Garbage Collection', 'High', 'Resolved', 'N. Kale', '2026-08-25');
INSERT INTO staging_complaints VALUES (231, 'GRV-2026-0231', '2026-08-23', 'W08', 'Garbage Collection', 'Low', 'Open', NULL, NULL);
INSERT INTO staging_complaints VALUES (232, 'GRV-2026-0232', '2026-08-23', 'W06', 'Drainage & Sewage', 'High', 'Open', 'R. Patil', NULL);
INSERT INTO staging_complaints VALUES (233, 'GRV-2026-0233', '2026-08-23', 'W07', 'Garbage Collection', 'Medium', 'In Progress', 'N. Kale', NULL);
INSERT INTO staging_complaints VALUES (234, 'GRV-2026-0234', '2026-08-23', 'W04', 'Street Lights', 'Medium', 'In Progress', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (235, 'GRV-2026-0235', '2026-08-23', 'W03', 'Drainage & Sewage', 'Medium', 'Resolved', 'A. Kulkarni', '2026-08-29');
INSERT INTO staging_complaints VALUES (236, 'GRV-2026-0236', '2026-08-23', 'W03', 'Drainage & Sewage', 'High', 'Resolved', 'D. Pawar', '2026-08-26');
INSERT INTO staging_complaints VALUES (237, 'GRV-2026-0237', '2026-08-24', 'W08', 'Drainage & Sewage', 'High', 'In Progress', 'M. Shinde', NULL);
INSERT INTO staging_complaints VALUES (238, 'GRV-2026-0238', '2026-08-24', 'W07', 'Drainage & Sewage', 'High', 'Resolved', 'P. Jadhav', '2026-08-25');
INSERT INTO staging_complaints VALUES (239, 'GRV-2026-0239', '2026-08-25', 'W07', 'Garbage Collection', 'High', 'Resolved', 'V. More', '2026-08-26');
INSERT INTO staging_complaints VALUES (240, 'GRV-2026-0240', '2026-08-25', 'W05', 'Road & Potholes', 'Medium', 'In Progress', 'D. Pawar', NULL);
INSERT INTO staging_complaints VALUES (241, 'GRV-2026-0241', '2026-08-25', 'W04', 'Garbage Collection', 'Medium', 'Resolved', 'P. Jadhav', '2026-08-28');
INSERT INTO staging_complaints VALUES (242, 'GRV-2026-0242', '2026-08-25', 'W07', 'Drainage & Sewage', 'Medium', 'Open', 'D. Pawar', NULL);
INSERT INTO staging_complaints VALUES (243, 'GRV-2026-0243', '2026-08-26', 'W08', 'Drainage & Sewage', 'High', 'In Progress', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (244, 'GRV-2026-0244', '2026-08-26', 'W01', 'Drainage & Sewage', 'Medium', 'Resolved', 'D. Pawar', '2026-08-29');
INSERT INTO staging_complaints VALUES (245, 'GRV-2026-0245', '2026-08-27', 'W05', 'Garbage Collection', 'Medium', 'Resolved', 'R. Patil', '2026-09-03');
INSERT INTO staging_complaints VALUES (246, 'GRV-2026-0246', '2026-08-27', 'W04', 'Drainage & Sewage', 'High', 'In Progress', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (247, 'GRV-2026-0247', '2026-08-27', 'W08', 'Water Supply', 'Medium', 'Resolved', 'S. Deshmukh', '2026-09-02');
INSERT INTO staging_complaints VALUES (248, 'GRV-2026-0248', '2026-08-27', 'W02', 'Road & Potholes', 'Medium', 'In Progress', 'V. More', NULL);
INSERT INTO staging_complaints VALUES (249, 'GRV-2026-0249', '2026-08-27', 'W07', 'Garbage Collection', 'Medium', 'Resolved', 'V. More', '2026-09-02');
INSERT INTO staging_complaints VALUES (250, 'GRV-2026-0250', '2026-08-28', 'W04', 'Public Toilets', 'Low', 'Resolved', 'V. More', '2026-09-11');
INSERT INTO staging_complaints VALUES (251, 'GRV-2026-0251', '2026-08-28', 'W01', 'Water Supply', 'Medium', 'In Progress', 'D. Pawar', NULL);
INSERT INTO staging_complaints VALUES (252, 'GRV-2026-0252', '2026-08-28', 'W01', 'Water Supply', 'High', 'Open', 'D. Pawar', NULL);
INSERT INTO staging_complaints VALUES (253, 'GRV-2026-0253', '2026-08-28', 'W06', 'Street Lights', 'High', 'Resolved', 'V. More', '2026-08-29');
INSERT INTO staging_complaints VALUES (254, 'GRV-2026-0254', '2026-08-29', 'W04', 'Garbage Collection', 'High', 'Open', NULL, NULL);
INSERT INTO staging_complaints VALUES (255, 'GRV-2026-0255', '2026-08-29', 'W01', 'Garbage Collection', 'Low', 'Resolved', 'S. Deshmukh', '2026-09-11');
INSERT INTO staging_complaints VALUES (256, 'GRV-2026-0256', '2026-08-29', 'W03', 'Public Toilets', 'Low', 'Open', NULL, NULL);
INSERT INTO staging_complaints VALUES (257, 'GRV-2026-0257', '2026-08-29', 'W02', 'Garbage Collection', 'High', 'Resolved', 'M. Shinde', '2026-08-30');
INSERT INTO staging_complaints VALUES (258, 'GRV-2026-0258', '2026-08-29', 'W03', 'Garbage Collection', 'Medium', 'Resolved', 'R. Patil', '2026-09-04');
INSERT INTO staging_complaints VALUES (259, 'GRV-2026-0259', '2026-08-30', 'W03', 'Street Lights', 'Medium', 'Resolved', 'N. Kale', '2026-09-01');
INSERT INTO staging_complaints VALUES (260, 'GRV-2026-0260', '2026-08-30', 'W05', 'Garbage Collection', 'High', 'Resolved', 'R. Patil', '2026-08-31');
INSERT INTO staging_complaints VALUES (261, 'GRV-2026-0261', '2026-08-30', 'W08', 'Drainage & Sewage', 'High', 'In Progress', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (262, 'GRV-2026-0262', '2026-08-30', 'W04', 'Street Lights', 'Low', 'Resolved', 'S. Deshmukh', '2026-09-12');
INSERT INTO staging_complaints VALUES (263, 'GRV-2026-0263', '2026-08-30', 'W06', 'Drainage & Sewage', 'Medium', 'Resolved', 'M. Shinde', '2026-09-02');
INSERT INTO staging_complaints VALUES (264, 'GRV-2026-0186', '2026-08-13', 'W04', 'Street Lights', 'Low', 'Resolved', 'D. Pawar', '2026-08-17');
INSERT INTO staging_complaints VALUES (265, 'GRV-2026-0264', '2026-08-30', 'W05', 'Public Toilets', 'High', 'Resolved', 'P. Jadhav', '2026-08-31');
INSERT INTO staging_complaints VALUES (266, 'GRV-2026-0265', '2026-08-31', NULL, 'Water Supply', 'Medium', 'In Progress', 'R. Patil', NULL);
INSERT INTO staging_complaints VALUES (267, 'GRV-2026-0266', '2026-08-31', 'W05', 'Garbage Collection', 'Low', 'Resolved', 'N. Kale', '2026-09-08');
INSERT INTO staging_complaints VALUES (268, 'GRV-2026-0267', '2026-08-31', 'W03', 'Water Supply', 'Medium', 'In Progress', 'M. Shinde', NULL);
INSERT INTO staging_complaints VALUES (269, 'GRV-2026-0268', '2026-08-31', 'W02', 'Street Lights', 'High', 'Open', NULL, NULL);
INSERT INTO staging_complaints VALUES (270, 'GRV-2026-0269', '2026-08-31', 'W03', 'Road & Potholes', 'High', 'Resolved', 'M. Shinde', '2026-09-02');
INSERT INTO staging_complaints VALUES (271, 'GRV-2026-0270', '2026-08-31', 'W02', 'Garbage Collection', 'Medium', 'In Progress', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (272, 'GRV-2026-0271', '2026-08-31', 'W05', NULL, 'Medium', 'Open', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (273, 'GRV-2026-0272', '2026-08-31', 'W03', 'Garbage Collection', 'Low', 'In Progress', 'R. Patil', NULL);
INSERT INTO staging_complaints VALUES (274, 'GRV-2026-0273', '2026-09-01', 'W01', 'Garbage Collection', 'Low', 'Resolved', 'A. Kulkarni', '2026-09-08');
INSERT INTO staging_complaints VALUES (275, 'GRV-2026-0274', '2026-09-01', 'W02', 'Drainage & Sewage', 'Low', 'Resolved', 'V. More', '2026-09-12');
INSERT INTO staging_complaints VALUES (276, 'GRV-2026-0275', '2026-09-01', 'W01', 'Road & Potholes', 'Low', 'Resolved', 'D. Pawar', '2026-09-05');
INSERT INTO staging_complaints VALUES (277, 'GRV-2026-0276', '2026-09-02', 'W03', 'Garbage Collection', 'High', 'Resolved', 'M. Shinde', '2026-09-05');
INSERT INTO staging_complaints VALUES (278, 'GRV-2026-0277', '2026-09-02', 'W05', 'Garbage Collection', 'High', 'Resolved', 'A. Kulkarni', '2026-09-04');
INSERT INTO staging_complaints VALUES (279, 'GRV-2026-0278', '2026-09-02', 'W04', 'Water Supply', 'Low', 'Resolved', 'D. Pawar', '2026-09-15');
INSERT INTO staging_complaints VALUES (280, 'GRV-2026-0279', '2026-09-02', 'W02', 'Garbage Collection', 'Low', 'Resolved', 'R. Patil', '2026-09-06');
INSERT INTO staging_complaints VALUES (281, 'GRV-2026-0280', '2026-09-02', 'W08', 'Water Supply', 'High', 'Resolved', 'S. Deshmukh', '2026-09-04');
INSERT INTO staging_complaints VALUES (282, 'GRV-2026-0281', '2026-09-02', 'W03', 'Water Supply', 'Medium', 'Resolved', 'M. Shinde', '2026-09-05');
INSERT INTO staging_complaints VALUES (283, 'GRV-2026-0282', '2026-09-03', 'W07', 'Water Supply', 'Medium', 'Resolved', 'N. Kale', '2026-09-09');
INSERT INTO staging_complaints VALUES (284, 'GRV-2026-0283', '2026-09-03', 'W01', 'Street Lights', 'Medium', 'Resolved', 'V. More', '2026-09-10');
INSERT INTO staging_complaints VALUES (285, 'GRV-2026-0284', '2026-09-03', 'W06', 'Drainage & Sewage', 'Medium', 'Open', NULL, NULL);
INSERT INTO staging_complaints VALUES (286, 'GRV-2026-0285', '2026-09-03', 'W07', 'Public Toilets', 'Medium', 'In Progress', 'R. Patil', NULL);
INSERT INTO staging_complaints VALUES (287, 'GRV-2026-0286', '2026-09-03', 'W04', 'Public Toilets', 'Low', 'Open', 'S. Deshmukh', NULL);
INSERT INTO staging_complaints VALUES (288, 'GRV-2026-0287', '2026-09-04', 'W07', 'Garbage Collection', 'High', 'Resolved', 'M. Shinde', '2026-09-06');
INSERT INTO staging_complaints VALUES (289, 'GRV-2026-0288', '2026-09-04', 'W08', 'Water Supply', 'Low', 'Open', NULL, NULL);
INSERT INTO staging_complaints VALUES (290, 'GRV-2026-0289', '2026-09-04', 'W05', 'Road & Potholes', 'High', 'Open', NULL, NULL);
INSERT INTO staging_complaints VALUES (291, 'GRV-2026-0290', '2026-09-05', 'W02', 'Road & Potholes', 'High', 'Resolved', 'N. Kale', '2026-09-07');
INSERT INTO staging_complaints VALUES (292, 'GRV-2026-0291', '2026-09-05', 'W02', 'Drainage & Sewage', 'High', 'Resolved', 'S. Deshmukh', '2026-09-07');
INSERT INTO staging_complaints VALUES (293, 'GRV-2026-0292', '2026-09-05', 'W05', 'Water Supply', 'Low', 'Resolved', 'R. Patil', '2026-09-15');
INSERT INTO staging_complaints VALUES (294, 'GRV-2026-0293', '2026-09-05', 'W05', 'Garbage Collection', 'Medium', 'In Progress', 'P. Jadhav', NULL);
INSERT INTO staging_complaints VALUES (295, 'GRV-2026-0294', '2026-09-05', 'W05', 'Drainage & Sewage', 'High', 'Open', NULL, NULL);
INSERT INTO staging_complaints VALUES (296, 'GRV-2026-0295', '2026-09-06', 'W06', 'Street Lights', 'Medium', 'Resolved', 'D. Pawar', '2026-09-11');
INSERT INTO staging_complaints VALUES (297, 'GRV-2026-0296', '2026-09-06', 'W04', 'Garbage Collection', 'Medium', 'Resolved', 'N. Kale', '2026-09-09');
INSERT INTO staging_complaints VALUES (298, 'GRV-2026-0297', '2026-09-06', 'W06', 'Public Toilets', 'Medium', 'Resolved', 'V. More', '2026-09-13');
INSERT INTO staging_complaints VALUES (299, 'GRV-2026-0298', '2026-09-06', 'W05', 'Garbage Collection', 'Medium', 'In Progress', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (300, 'GRV-2026-0299', '2026-09-06', 'W02', 'Road & Potholes', 'High', 'In Progress', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (301, 'GRV-2026-0300', '2026-09-06', 'W06', 'Garbage Collection', 'Low', 'In Progress', 'M. Shinde', NULL);
INSERT INTO staging_complaints VALUES (302, 'GRV-2026-0301', '2026-09-07', 'W03', 'Public Toilets', 'Medium', 'Resolved', 'R. Patil', '2026-09-12');
INSERT INTO staging_complaints VALUES (303, 'GRV-2026-0302', '2026-10-05', 'W05', 'Street Lights', 'Medium', 'In Progress', 'D. Pawar', NULL);
INSERT INTO staging_complaints VALUES (304, 'GRV-2026-0303', '2026-09-07', 'W03', 'Drainage & Sewage', 'Medium', 'Resolved', 'N. Kale', '2026-09-09');
INSERT INTO staging_complaints VALUES (305, 'GRV-2026-0304', '2026-09-07', 'W08', 'Road & Potholes', 'Medium', 'Resolved', 'R. Patil', '2026-09-14');
INSERT INTO staging_complaints VALUES (306, 'GRV-2026-0305', '2026-09-07', 'W02', 'Garbage Collection', 'Low', 'Resolved', 'D. Pawar', '2026-09-15');
INSERT INTO staging_complaints VALUES (307, 'GRV-2026-0306', '2026-09-07', 'W06', 'Drainage & Sewage', 'Medium', 'Resolved', 'N. Kale', '2026-09-12');
INSERT INTO staging_complaints VALUES (308, 'GRV-2026-0122', '2026-07-25', 'W07', 'Road & Potholes', 'Low', 'Resolved', 'N. Kale', '2026-07-29');
INSERT INTO staging_complaints VALUES (309, 'GRV-2026-0307', '2026-09-08', 'W08', 'Street Lights', 'High', 'Resolved', 'P. Jadhav', '2026-09-09');
INSERT INTO staging_complaints VALUES (310, 'GRV-2026-0308', '2026-09-08', 'W07', 'Road & Potholes', 'Medium', 'In Progress', 'V. More', NULL);
INSERT INTO staging_complaints VALUES (311, 'GRV-2026-0309', '2026-09-08', 'W04', 'Drainage & Sewage', 'Low', 'In Progress', 'N. Kale', NULL);
INSERT INTO staging_complaints VALUES (312, 'GRV-2026-0310', '2026-09-08', 'W01', 'Road & Potholes', 'Low', 'Resolved', 'D. Pawar', '2026-09-17');
INSERT INTO staging_complaints VALUES (313, 'GRV-2026-0311', '2026-09-09', 'W05', 'Drainage & Sewage', 'Medium', 'Open', NULL, NULL);
INSERT INTO staging_complaints VALUES (314, 'GRV-2026-0312', '2026-09-09', 'W07', 'Garbage Collection', 'Medium', 'Resolved', 'V. More', '2026-09-11');
INSERT INTO staging_complaints VALUES (315, 'GRV-2026-0313', '2026-09-09', NULL, 'Garbage Collection', 'High', 'In Progress', 'V. More', NULL);
INSERT INTO staging_complaints VALUES (316, 'GRV-2026-0314', '2026-09-09', 'W03', 'Garbage Collection', 'Medium', 'Open', 'D. Pawar', NULL);
INSERT INTO staging_complaints VALUES (317, 'GRV-2026-0315', '2026-09-09', 'W06', 'Road & Potholes', 'Low', 'Open', 'V. More', NULL);
INSERT INTO staging_complaints VALUES (318, 'GRV-2026-0316', '2026-09-09', 'W05', 'Drainage & Sewage', 'Low', 'Resolved', 'P. Jadhav', '2026-09-13');
INSERT INTO staging_complaints VALUES (319, 'GRV-2026-0317', '2026-09-10', 'W07', 'Street Lights', 'Low', 'In Progress', 'M. Shinde', NULL);
INSERT INTO staging_complaints VALUES (320, 'GRV-2026-0318', '2026-09-10', 'W03', 'Garbage Collection', 'High', 'Resolved', 'S. Deshmukh', '2026-09-12');
INSERT INTO staging_complaints VALUES (321, 'GRV-2026-0145', '2026-07-30', 'W07', 'Water Supply', 'High', 'Resolved', 'P. Jadhav', '2026-07-31');
INSERT INTO staging_complaints VALUES (322, 'GRV-2026-0319', '2026-09-10', 'W01', 'Drainage & Sewage', 'Low', 'In Progress', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (323, 'GRV-2026-0320', '2026-10-05', 'W01', 'Drainage & Sewage', 'Medium', 'In Progress', 'S. Deshmukh', NULL);
INSERT INTO staging_complaints VALUES (324, 'GRV-2026-0321', '2026-09-10', 'W04', 'Garbage Collection', 'Medium', 'Resolved', 'P. Jadhav', '2026-09-16');
INSERT INTO staging_complaints VALUES (325, 'GRV-2026-0322', '2026-09-10', 'W03', 'Road & Potholes', 'Low', 'In Progress', 'S. Deshmukh', NULL);
INSERT INTO staging_complaints VALUES (326, 'GRV-2026-0323', '2026-09-10', 'W02', 'Water Supply', 'Medium', 'Resolved', 'D. Pawar', '2026-09-12');
INSERT INTO staging_complaints VALUES (327, 'GRV-2026-0324', '2026-09-10', 'W01', 'Road & Potholes', 'Medium', 'Open', NULL, NULL);
INSERT INTO staging_complaints VALUES (328, 'GRV-2026-0325', '2026-09-11', 'W05', 'Water Supply', 'Medium', 'Resolved', 'S. Deshmukh', '2026-09-14');
INSERT INTO staging_complaints VALUES (329, 'GRV-2026-0326', '2026-09-11', 'W02', 'Road & Potholes', 'Low', 'Resolved', 'N. Kale', '2026-09-19');
INSERT INTO staging_complaints VALUES (330, 'GRV-2026-0327', '2026-09-11', 'W07', 'Water Supply', 'Medium', 'Open', 'M. Shinde', NULL);
INSERT INTO staging_complaints VALUES (331, 'GRV-2026-0328', '2026-09-11', 'W03', 'Drainage & Sewage', 'High', 'Resolved', 'D. Pawar', '2026-09-14');
INSERT INTO staging_complaints VALUES (332, 'GRV-2026-0329', '2026-09-12', 'W08', 'Drainage & Sewage', 'Medium', 'In Progress', 'N. Kale', NULL);
INSERT INTO staging_complaints VALUES (333, 'GRV-2026-0330', '2026-09-12', 'W07', 'Street Lights', 'Medium', 'Resolved', 'D. Pawar', '2026-09-19');
INSERT INTO staging_complaints VALUES (334, 'GRV-2026-0073', '2026-07-16', 'W06', 'Street Lights', 'Low', 'Resolved', 'P. Jadhav', '2026-07-21');
INSERT INTO staging_complaints VALUES (335, 'GRV-2026-0331', '2026-09-12', 'W02', 'Water Supply', 'Low', 'Resolved', 'R. Patil', '2026-09-19');
INSERT INTO staging_complaints VALUES (336, 'GRV-2026-0332', '2026-09-12', 'W07', 'Water Supply', 'Low', 'In Progress', 'N. Kale', NULL);
INSERT INTO staging_complaints VALUES (337, 'GRV-2026-0333', '2026-09-12', 'W02', 'Drainage & Sewage', 'Medium', 'Resolved', 'M. Shinde', '2026-09-19');
INSERT INTO staging_complaints VALUES (338, 'GRV-2026-0334', '2026-09-12', 'W06', 'Garbage Collection', 'Medium', 'Resolved', 'A. Kulkarni', '2026-09-14');
INSERT INTO staging_complaints VALUES (339, 'GRV-2026-0335', '2026-09-13', 'W03', 'Drainage & Sewage', 'High', 'Resolved', 'R. Patil', '2026-09-14');
INSERT INTO staging_complaints VALUES (340, 'GRV-2026-0336', '2026-09-13', 'W04', 'Garbage Collection', 'Medium', 'Resolved', 'N. Kale', '2026-09-17');
INSERT INTO staging_complaints VALUES (341, 'GRV-2026-0337', '2026-09-13', 'W04', 'Drainage & Sewage', 'Low', 'Resolved', 'M. Shinde', '2026-09-21');
INSERT INTO staging_complaints VALUES (342, 'GRV-2026-0338', '2026-09-13', 'W03', 'Drainage & Sewage', 'Medium', 'Open', NULL, NULL);
INSERT INTO staging_complaints VALUES (343, 'GRV-2026-0339', '2026-09-13', 'W04', 'Garbage Collection', 'Low', 'Resolved', 'R. Patil', '2026-09-22');
INSERT INTO staging_complaints VALUES (344, 'GRV-2026-0340', '2026-09-13', 'W02', 'Road & Potholes', 'High', 'In Progress', 'N. Kale', NULL);
INSERT INTO staging_complaints VALUES (345, 'GRV-2026-0341', '2026-09-13', 'W03', 'Water Supply', 'Low', 'Resolved', 'S. Deshmukh', '2026-09-20');
INSERT INTO staging_complaints VALUES (346, 'GRV-2026-0342', '2026-09-14', 'W04', 'Street Lights', 'Low', 'Resolved', 'S. Deshmukh', '2026-09-25');
INSERT INTO staging_complaints VALUES (347, 'GRV-2026-0343', '2026-09-14', 'W05', 'Water Supply', 'Low', 'Resolved', 'S. Deshmukh', '2026-09-25');
INSERT INTO staging_complaints VALUES (348, 'GRV-2026-0344', '2026-09-14', 'W07', 'Drainage & Sewage', 'High', 'Resolved', 'D. Pawar', '2026-09-16');
INSERT INTO staging_complaints VALUES (349, 'GRV-2026-0345', '2026-09-15', 'W03', 'Road & Potholes', 'Low', 'In Progress', 'V. More', NULL);
INSERT INTO staging_complaints VALUES (350, 'GRV-2026-0346', '2026-09-15', 'W06', 'Street Lights', 'Medium', 'In Progress', 'D. Pawar', NULL);
INSERT INTO staging_complaints VALUES (351, 'GRV-2026-0347', '2026-09-15', 'W06', 'Drainage & Sewage', 'Low', 'In Progress', 'P. Jadhav', NULL);
INSERT INTO staging_complaints VALUES (352, 'GRV-2026-0348', '2026-09-16', 'W04', 'Water Supply', 'Low', 'In Progress', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (353, 'GRV-2026-0349', '2026-09-16', 'W05', 'Garbage Collection', 'Medium', 'Resolved', 'P. Jadhav', '2026-09-22');
INSERT INTO staging_complaints VALUES (354, 'GRV-2026-0350', '2026-09-16', 'W04', 'Street Lights', 'Low', 'Open', 'N. Kale', NULL);
INSERT INTO staging_complaints VALUES (355, 'GRV-2026-0351', '2026-09-16', 'W01', 'Street Lights', 'Medium', 'Resolved', 'P. Jadhav', '2026-09-22');
INSERT INTO staging_complaints VALUES (356, 'GRV-2026-0352', '2026-09-17', 'W01', 'Road & Potholes', 'Low', 'Open', 'V. More', NULL);
INSERT INTO staging_complaints VALUES (357, 'GRV-2026-0353', '2026-09-17', 'W02', 'Water Supply', 'Low', 'Resolved', 'M. Shinde', '2026-09-29');
INSERT INTO staging_complaints VALUES (358, 'GRV-2026-0354', '2026-09-17', 'W07', 'Drainage & Sewage', 'High', 'In Progress', 'D. Pawar', NULL);
INSERT INTO staging_complaints VALUES (359, 'GRV-2026-0355', '2026-09-17', 'W04', 'Garbage Collection', 'Medium', 'Resolved', 'R. Patil', '2026-09-21');
INSERT INTO staging_complaints VALUES (360, 'GRV-2026-0356', '2026-09-17', 'W05', 'Garbage Collection', 'High', 'Resolved', 'M. Shinde', '2026-09-18');
INSERT INTO staging_complaints VALUES (361, 'GRV-2026-0357', '2026-09-17', 'W01', 'Garbage Collection', 'Medium', 'Resolved', 'S. Deshmukh', '2026-09-20');
INSERT INTO staging_complaints VALUES (362, 'GRV-2026-0358', '2026-09-17', 'W03', 'Water Supply', 'Medium', 'In Progress', 'D. Pawar', NULL);
INSERT INTO staging_complaints VALUES (363, 'GRV-2026-0037', '2026-07-09', 'W08', 'Street Lights', 'Low', 'Resolved', 'P. Jadhav', '2026-07-13');
INSERT INTO staging_complaints VALUES (364, 'GRV-2026-0359', '2026-09-18', 'W08', 'Drainage & Sewage', 'Medium', 'Resolved', 'P. Jadhav', '2026-09-23');
INSERT INTO staging_complaints VALUES (365, 'GRV-2026-0360', '2026-09-18', 'W04', 'Water Supply', 'Low', 'Resolved', 'N. Kale', '2026-09-29');
INSERT INTO staging_complaints VALUES (366, 'GRV-2026-0361', '2026-09-18', 'W03', 'Road & Potholes', 'High', 'In Progress', 'N. Kale', NULL);
INSERT INTO staging_complaints VALUES (367, 'GRV-2026-0362', '2026-09-18', 'W05', 'Road & Potholes', 'High', 'Resolved', 'A. Kulkarni', '2026-09-20');
INSERT INTO staging_complaints VALUES (368, 'GRV-2026-0363', '2026-09-19', 'W04', 'Water Supply', 'Medium', 'Resolved', 'S. Deshmukh', '2026-09-22');
INSERT INTO staging_complaints VALUES (369, 'GRV-2026-0364', '2026-09-19', 'W06', 'Water Supply', 'Medium', 'Resolved', 'A. Kulkarni', '2026-09-24');
INSERT INTO staging_complaints VALUES (370, 'GRV-2026-0365', '2026-09-20', 'W08', 'Water Supply', 'Low', 'Resolved', 'P. Jadhav', '2026-09-29');
INSERT INTO staging_complaints VALUES (371, 'GRV-2026-0366', '2026-09-20', 'W07', 'Water Supply', 'Medium', 'Open', 'V. More', NULL);
INSERT INTO staging_complaints VALUES (372, 'GRV-2026-0367', '2026-09-20', 'W05', 'Road & Potholes', 'Medium', 'In Progress', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (373, 'GRV-2026-0368', '2026-09-20', 'W03', 'Water Supply', 'Medium', 'Resolved', 'R. Patil', '2026-09-23');
INSERT INTO staging_complaints VALUES (374, 'GRV-2026-0369', '2026-09-20', 'W05', 'Water Supply', 'Low', 'In Progress', 'R. Patil', NULL);
INSERT INTO staging_complaints VALUES (375, 'GRV-2026-0370', '2026-09-21', 'W04', 'Street Lights', 'Medium', 'Resolved', 'V. More', '2026-09-26');
INSERT INTO staging_complaints VALUES (376, 'GRV-2026-0371', '2026-09-21', 'W01', 'Road & Potholes', 'Medium', 'Resolved', 'N. Kale', '2026-09-26');
INSERT INTO staging_complaints VALUES (377, 'GRV-2026-0372', '2026-09-21', 'W08', 'Road & Potholes', 'Low', 'Open', NULL, NULL);
INSERT INTO staging_complaints VALUES (378, 'GRV-2026-0373', '2026-09-22', 'W03', 'Garbage Collection', 'Medium', 'In Progress', 'D. Pawar', NULL);
INSERT INTO staging_complaints VALUES (379, 'GRV-2026-0374', '2026-09-22', 'W01', 'Street Lights', 'Medium', 'In Progress', 'M. Shinde', NULL);
INSERT INTO staging_complaints VALUES (380, 'GRV-2026-0375', '2026-09-22', 'W07', 'Street Lights', 'High', 'Resolved', 'A. Kulkarni', '2026-09-23');
INSERT INTO staging_complaints VALUES (381, 'GRV-2026-0376', '2026-09-22', 'W06', 'Garbage Collection', 'Medium', 'Resolved', 'R. Patil', '2026-09-24');
INSERT INTO staging_complaints VALUES (382, 'GRV-2026-0377', '2026-09-22', 'W05', 'Road & Potholes', 'High', 'Resolved', 'V. More', '2026-09-24');
INSERT INTO staging_complaints VALUES (383, 'GRV-2026-0378', '2026-09-23', 'W06', 'Garbage Collection', 'Medium', 'In Progress', 'R. Patil', NULL);
INSERT INTO staging_complaints VALUES (384, 'GRV-2026-0379', '2026-09-23', 'W02', 'Public Toilets', 'Low', 'In Progress', 'V. More', NULL);
INSERT INTO staging_complaints VALUES (385, 'GRV-2026-0380', '2026-09-23', 'W07', 'Garbage Collection', 'Medium', 'In Progress', 'R. Patil', NULL);
INSERT INTO staging_complaints VALUES (386, 'GRV-2026-0381', '2026-09-23', 'W01', 'Drainage & Sewage', 'Medium', 'In Progress', 'D. Pawar', NULL);
INSERT INTO staging_complaints VALUES (387, 'GRV-2026-0382', '2026-09-24', 'W06', 'Street Lights', 'High', 'Open', 'M. Shinde', NULL);
INSERT INTO staging_complaints VALUES (388, 'GRV-2026-0383', '2026-09-24', 'W02', 'Garbage Collection', 'Medium', 'Resolved', 'M. Shinde', '2026-09-29');
INSERT INTO staging_complaints VALUES (389, 'GRV-2026-0384', '2026-09-24', 'W05', 'Garbage Collection', 'High', 'In Progress', 'P. Jadhav', NULL);
INSERT INTO staging_complaints VALUES (390, 'GRV-2026-0385', '2026-09-25', 'W08', 'Street Lights', 'Medium', 'Resolved', 'S. Deshmukh', '2026-09-29');
INSERT INTO staging_complaints VALUES (391, 'GRV-2026-0386', '2026-09-26', 'W02', 'Street Lights', 'Low', 'Open', NULL, NULL);
INSERT INTO staging_complaints VALUES (392, 'GRV-2026-0387', '2026-09-26', 'W02', 'Water Supply', 'Medium', 'Open', NULL, NULL);
INSERT INTO staging_complaints VALUES (393, 'GRV-2026-0388', '2026-09-26', 'W03', 'Garbage Collection', 'Medium', 'In Progress', 'D. Pawar', NULL);
INSERT INTO staging_complaints VALUES (394, 'GRV-2026-0389', '2026-09-26', 'W01', 'Road & Potholes', 'High', 'In Progress', 'A. Kulkarni', NULL);
INSERT INTO staging_complaints VALUES (395, 'GRV-2026-0390', '2026-09-26', 'W04', 'Water Supply', 'Medium', 'In Progress', 'R. Patil', NULL);
INSERT INTO staging_complaints VALUES (396, 'GRV-2026-0391', '2026-09-26', 'W04', 'Garbage Collection', 'Low', 'Open', NULL, NULL);
INSERT INTO staging_complaints VALUES (397, 'GRV-2026-0392', '2026-09-27', 'W06', 'Water Supply', 'Low', 'Open', 'P. Jadhav', NULL);
INSERT INTO staging_complaints VALUES (398, 'GRV-2026-0393', '2026-09-27', 'W06', 'Water Supply', 'Medium', 'In Progress', 'V. More', NULL);
INSERT INTO staging_complaints VALUES (399, 'GRV-2026-0394', '2026-09-27', 'W02', 'Water Supply', 'Medium', 'Resolved', 'M. Shinde', '2026-09-29');
INSERT INTO staging_complaints VALUES (400, 'GRV-2026-0395', '2026-09-27', 'W08', 'Drainage & Sewage', 'High', 'Resolved', 'D. Pawar', '2026-09-29');
INSERT INTO staging_complaints VALUES (401, 'GRV-2026-0396', '2026-09-27', 'W02', 'Water Supply', 'High', 'Resolved', 'R. Patil', '2026-09-28');
INSERT INTO staging_complaints VALUES (402, 'GRV-2026-0397', '2026-09-28', 'W07', 'Garbage Collection', 'Medium', 'In Progress', 'P. Jadhav', NULL);
INSERT INTO staging_complaints VALUES (403, 'GRV-2026-0398', '2026-09-28', 'W05', 'Garbage Collection', 'Medium', 'In Progress', 'V. More', NULL);
INSERT INTO staging_complaints VALUES (404, 'GRV-2026-0399', '2026-09-28', 'W08', 'Public Toilets', 'Medium', 'Open', 'R. Patil', NULL);
INSERT INTO staging_complaints VALUES (405, 'GRV-2026-0345', '2026-09-15', 'W03', 'Road & Potholes', 'Low', 'In Progress', 'V. More', NULL);
INSERT INTO staging_complaints VALUES (406, 'GRV-2026-0400', '2026-09-28', 'W07', 'Street Lights', 'Medium', 'Open', NULL, NULL);

-- ============ PART 2: CLEAN AND LOAD ============
-- STEP 1: send every bad row to rejected_complaints with the FIRST failing reason
INSERT INTO rejected_complaints (stg_id, complaint_id, reject_reason)
SELECT stg_id, complaint_id, reason
FROM (
  SELECT s.stg_id, s.complaint_id,
         CASE
           WHEN ROW_NUMBER() OVER (PARTITION BY s.complaint_id ORDER BY s.stg_id) > 1 THEN 'Duplicate ID'
           WHEN s.ward_code IS NULL OR s.ward_code = ''             THEN 'Missing ward'
           WHEN s.category_name IS NULL OR s.category_name = ''     THEN 'Missing category'
           WHEN s.status = 'Resolved' AND s.date_resolved IS NULL   THEN 'Resolved without date'
           WHEN s.date_resolved IS NOT NULL AND s.date_resolved < s.date_logged THEN 'Resolved before logged'
           WHEN s.date_logged > '2026-09-29'                              THEN 'Future date'
           ELSE NULL
         END AS reason
  FROM staging_complaints s
) t
WHERE reason IS NOT NULL;

-- STEP 2: load only the good rows into the clean table
INSERT INTO complaints (complaint_id, date_logged, ward_code, category_id, priority, status, assigned_to, date_resolved)
SELECT s.complaint_id, s.date_logged, s.ward_code, c.category_id, s.priority, s.status, s.assigned_to, s.date_resolved
FROM staging_complaints s
JOIN categories c ON c.category_name = s.category_name
WHERE s.stg_id NOT IN (SELECT stg_id FROM rejected_complaints);

-- ============ PART 3: ANALYSIS QUERIES ============

-- Q1. Data-quality checks on staging data
SELECT 'Duplicate complaint IDs' AS check_name, COUNT(*) AS rows_found
FROM (SELECT complaint_id FROM staging_complaints GROUP BY complaint_id HAVING COUNT(*) > 1) d
UNION ALL SELECT 'Missing ward', COUNT(*) FROM staging_complaints WHERE ward_code IS NULL OR ward_code = ''
UNION ALL SELECT 'Missing category', COUNT(*) FROM staging_complaints WHERE category_name IS NULL OR category_name = ''
UNION ALL SELECT 'Resolved but no resolved date', COUNT(*) FROM staging_complaints WHERE status = 'Resolved' AND date_resolved IS NULL
UNION ALL SELECT 'Resolved date earlier than logged date', COUNT(*) FROM staging_complaints WHERE date_resolved IS NOT NULL AND date_resolved < date_logged
UNION ALL SELECT 'Logged date after report date', COUNT(*) FROM staging_complaints WHERE date_logged > '2026-09-29';

-- Q2. Rejected rows by reason (exception report)
SELECT reject_reason, COUNT(*) AS rows_rejected
FROM rejected_complaints
GROUP BY reject_reason
ORDER BY rows_rejected DESC, reject_reason;

-- Q3. Category-wise total, resolved, pending and average resolution days
SELECT cat.category_name, cat.department,
       COUNT(*) AS total,
       SUM(CASE WHEN c.status = 'Resolved' THEN 1 ELSE 0 END) AS resolved,
       SUM(CASE WHEN c.status <> 'Resolved' THEN 1 ELSE 0 END) AS pending,
       ROUND(AVG(CASE WHEN c.status = 'Resolved' THEN DATEDIFF(c.date_resolved, c.date_logged) END), 1) AS avg_resolution_days
FROM complaints c
JOIN categories cat ON cat.category_id = c.category_id
GROUP BY cat.category_name, cat.department
ORDER BY total DESC;

-- Q4. SLA compliance of resolved complaints by priority
SELECT p.priority, p.sla_days,
       COUNT(*) AS resolved,
       SUM(CASE WHEN DATEDIFF(c.date_resolved, c.date_logged) <= p.sla_days THEN 1 ELSE 0 END) AS within_sla,
       ROUND(100.0 * SUM(CASE WHEN DATEDIFF(c.date_resolved, c.date_logged) <= p.sla_days THEN 1 ELSE 0 END) / COUNT(*), 1) AS within_sla_pct
FROM complaints c
JOIN priorities p ON p.priority = c.priority
WHERE c.status = 'Resolved'
GROUP BY p.priority, p.sla_days
ORDER BY p.sla_days;

-- Q5. Overdue open complaints (older than SLA) by ward
SELECT w.ward_name, COUNT(*) AS overdue_open
FROM complaints c
JOIN priorities p ON p.priority = c.priority
JOIN wards w ON w.ward_code = c.ward_code
WHERE c.status <> 'Resolved'
  AND DATEDIFF('2026-09-29', c.date_logged) > p.sla_days
GROUP BY w.ward_name
ORDER BY overdue_open DESC, w.ward_name;

-- Q6. Ward-wise workload (total, resolved, pending)
SELECT w.ward_name,
       COUNT(*) AS total,
       SUM(CASE WHEN c.status = 'Resolved' THEN 1 ELSE 0 END) AS resolved,
       SUM(CASE WHEN c.status <> 'Resolved' THEN 1 ELSE 0 END) AS pending
FROM complaints c
JOIN wards w ON w.ward_code = c.ward_code
GROUP BY w.ward_name
ORDER BY pending DESC, w.ward_name;

-- Q7. Monthly complaints logged and resolved
SELECT DATE_FORMAT(date_logged, '%Y-%m') AS month_logged,
       COUNT(*) AS logged,
       SUM(CASE WHEN status = 'Resolved' THEN 1 ELSE 0 END) AS resolved
FROM complaints
GROUP BY DATE_FORMAT(date_logged, '%Y-%m')
ORDER BY month_logged;

-- Q8. Open / In Progress complaints with no officer assigned
SELECT complaint_id, date_logged, ward_code, priority, status
FROM complaints
WHERE status <> 'Resolved' AND assigned_to IS NULL
ORDER BY date_logged;
