/*
 Navicat Premium Data Transfer

 Source Server         : txy2
 Source Server Type    : MySQL
 Source Server Version : 50718
 Source Host           : sh-cynosdbmysql-grp-cdxgau56.sql.tencentcdb.com:22995
 Source Schema         : nmrih_models

 Target Server Type    : MySQL
 Target Server Version : 50718
 File Encoding         : 65001

 Date: 08/12/2022 16:04:58
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for nmrih_model
-- ----------------------------
DROP TABLE IF EXISTS `nmrih_model`;
CREATE TABLE `nmrih_model`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '皮肤的唯一标识',
  `model_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '模型名字',
  `model_sort` int(11) NULL DEFAULT 5 COMMENT '越大越靠前',
  `model_file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '模型文件路径加文件名',
  `pay_money` int(11) NULL DEFAULT 0 COMMENT '支付金额',
  `money_or_free_or_integral` int(11) NULL DEFAULT 3 COMMENT '1会员，2免费, 3积分(弃用)',
  `need_integral` int(255) NULL DEFAULT 0 COMMENT '购买的积分数量',
  `is_open` int(1) NULL DEFAULT 1 COMMENT '0关闭,1开启',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `weiyi`(`model_title`) USING BTREE COMMENT '唯一title',
  INDEX `zuhe`(`model_sort`, `money_or_free_or_integral`, `is_open`) USING BTREE COMMENT '组合查询列表索引'
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of nmrih_model
-- ----------------------------
INSERT INTO `nmrih_model` VALUES (1, 'barbara', '芭芭拉', 5, 'models/barbara/barbara.mdl', 0, 2, 0, 1);
INSERT INTO `nmrih_model` VALUES (2, 'p_frat', '大老鼠', 6, 'models/player/biohazard/673542016/p_frat.mdl', 100, 1, 0, 1);
INSERT INTO `nmrih_model` VALUES (3, 'karin', '卡琳', 6, 'models/karin.mdl', 100, 1, 0, 1);
INSERT INTO `nmrih_model` VALUES (4, 'p_bateman', '官方-Bateman', 1, 'models/player/p_bateman.mdl', 0, 2, 0, 1);
INSERT INTO `nmrih_model` VALUES (5, 'p_butcher', '官方-Butcher', 1, 'models/player/p_butcher.mdl', 0, 2, 0, 1);
INSERT INTO `nmrih_model` VALUES (6, 'p_hunter', '官方-Hunter', 1, 'models/player/p_hunter.mdl', 0, 2, 0, 1);
INSERT INTO `nmrih_model` VALUES (7, 'p_jive', '官方-Jive', 1, 'models/player/p_jive.mdl', 0, 2, 0, 1);
INSERT INTO `nmrih_model` VALUES (8, 'p_molotov', '官方-Molotov', 1, 'models/player/p_molotov.mdl', 0, 2, 0, 1);
INSERT INTO `nmrih_model` VALUES (9, 'p_roje', '官方-Roje', 1, 'models/player/p_roje.mdl', 0, 2, 0, 1);
INSERT INTO `nmrih_model` VALUES (10, 'p_wally', '官方-Wally', 1, 'models/player/p_wally.mdl', 0, 2, 0, 1);
INSERT INTO `nmrih_model` VALUES (11, 'p_badass', '官方-Badass', 1, 'models/player/p_badass.mdl', 0, 2, 0, 1);

-- ----------------------------
-- Table structure for nmrih_user
-- ----------------------------
DROP TABLE IF EXISTS `nmrih_user`;
CREATE TABLE `nmrih_user`  (
  `steam_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'steamid',
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '玩家名字',
  `integral` int(10) NULL DEFAULT 0 COMMENT '积分',
  `pay_money` int(10) NULL DEFAULT 0 COMMENT '捐款金额',
  `user_status` int(1) NULL DEFAULT 1 COMMENT '1.正常 2.冻结',
  `lost_model_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'Undefined' COMMENT '玩家最后使用的模型皮肤',
  PRIMARY KEY (`steam_id`) USING BTREE,
  UNIQUE INDEX `index`(`steam_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of nmrih_user
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
