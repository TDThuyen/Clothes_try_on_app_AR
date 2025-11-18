/*
  Warnings:

  - Added the required column `first_name` to the `orders` table without a default value. This is not possible if the table is not empty.
  - Added the required column `last_name` to the `orders` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE `orders` ADD COLUMN `first_name` VARCHAR(25) NOT NULL,
    ADD COLUMN `last_name` VARCHAR(25) NOT NULL;
