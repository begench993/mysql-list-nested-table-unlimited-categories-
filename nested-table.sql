    DELIMITER $$
    CREATE PROCEDURE `categories_get_tree`(
        node_id INT UNSIGNED
    ) COMMENT 'Query all descendants nodes by a node id, return as a result set'
    BEGIN
    SELECT node.`id`,
           node.`parent_id`,
           CONCAT(
                   REPEAT('-', path.`path_length`),
                   node.`name`
               ) AS name,
           path.`path_length`,
           GROUP_CONCAT(
                   crumbs.`ust_id` SEPARATOR ','
               ) AS breadcrumbs
    FROM `categories` AS node
             JOIN `categories_paths` AS path
                  ON node.`id` = path.`alt_id`
             JOIN `categories_paths` AS crumbs
                  ON crumbs.`alt_id` = path.`alt_id`
    WHERE path.`ust_id` = `node_id`
      AND node.`is_deleted` = 0
    GROUP BY node.`id`
    ORDER BY breadcrumbs;
    END$$
    DELIMITER ;

DELIMITER $$
    CREATE PROCEDURE `categories_node_add`(IN `param_node_new_id` INT UNSIGNED,
                                           IN `param_node_parent_id` INT UNSIGNED) COMMENT 'Adding new paths prefix_nodes_paths table'
    BEGIN
  -- Update paths information
    INSERT INTO `categories_paths` (`ust_id`,
                                    `alt_id`,
                                    `path_length`)
    SELECT `ust_id`,
           `param_node_new_id`,
           `path_length` + 1
    FROM `categories_paths`
    WHERE `alt_id` = `param_node_parent_id`
    UNION
        ALL
    SELECT `param_node_new_id`,
           `param_node_new_id`,
           0;
    END$$
    DELIMITER ;

DELIMITER $$
    CREATE PROCEDURE `categories_node_hide`(
        `node_id` INT UNSIGNED,
        `deleted` INT UNSIGNED
    ) COMMENT 'Delete a node and its descendant nodes(update is_deleted = 1)'
    BEGIN
    UPDATE
        `categories` AS d
        JOIN `categories_paths` AS p
    ON d.`id` = p.`alt_id`
        SET d.`is_deleted` = deleted
    WHERE p.`ust_id` = node_id;
    END$$
    DELIMITER ;

    CREATE TABLE `categories`
    (
        `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
        `parent_id`   INT UNSIGNED DEFAULT NULL,
        `merchant_id` INT UNSIGNED NOT NULL,
        `name`        varchar(250) NOT NULL,
        `is_deleted`  BOOLEAN      NOT NULL DEFAULT FALSE,
        PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

    ALTER TABLE `categories`
        ADD CONSTRAINT `categories_parent_id` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
