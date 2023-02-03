/*
 Navicat Premium Data Transfer

 Source Server         : yun1
 Source Server Type    : MySQL
 Source Server Version : 50718
 Source Host           : sh-cynosdbmysql-grp-gomruqca.sql.tencentcdb.com:25187
 Source Schema         : nmrih

 Target Server Type    : MySQL
 Target Server Version : 50718
 File Encoding         : 65001

 Date: 03/02/2023 16:12:11
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for nmrih_user
-- ----------------------------
DROP TABLE IF EXISTS `nmrih_user`;
CREATE TABLE `nmrih_user`  (
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `steam_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'steamid',
  `exper_num` int(10) NULL DEFAULT 0 COMMENT '经验',
  `death_num` int(10) NULL DEFAULT 0 COMMENT '死亡数',
  `l_v_num` int(10) NULL DEFAULT 0 COMMENT '等级',
  `kill_num` int(10) NULL DEFAULT 0 COMMENT '击杀数',
  `money_num` int(10) NULL DEFAULT 0 COMMENT '金币',
  `pay_money` int(10) NULL DEFAULT 0 COMMENT '捐款金额',
  PRIMARY KEY (`steam_id`) USING BTREE,
  UNIQUE INDEX `index`(`steam_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
