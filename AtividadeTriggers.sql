CREATE DATABASE extriggers
GO
USE extriggers

CREATE TABLE servico(
id INT NOT NULL,
nome VARCHAR(100),
preco DECIMAL(7,2)
PRIMARY KEY(ID))
 
CREATE TABLE depto(
codigo INT not null,
nome VARCHAR(100),
total_salarios DECIMAL(7,2)
PRIMARY KEY(codigo))
 
CREATE TABLE funcionario(
id INT NOT NULL,
nome VARCHAR(100),
salario DECIMAL(7,2),
depto INT NOT NULL
PRIMARY KEY(id)
FOREIGN KEY (depto) REFERENCES depto(codigo))
 
INSERT INTO servico VALUES
(1, 'Orçamento', 20.00),
(2, 'Manutenção preventiva', 85.00)
 
INSERT INTO depto (codigo, nome) VALUES
(1,'RH'),
(2,'DTI')

GO
CREATE TRIGGER t_atualizasalario ON funcionario
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE	@l_insert INT,
			@l_delete INT,
			@total DECIMAL(7,2),
			@cod_depto INT,
			@dif DECIMAL(7,2),
			@salario DECIMAL(7,2)

	SET @l_insert = (SELECT COUNT(*) FROM INSERTED)
	SET @l_delete = (SELECT COUNT(*) FROM DELETED)
	

	IF(@l_insert = 1)
		BEGIN
			SET @cod_depto = (SELECT depto FROM INSERTED)
			SET @total = (SELECT total_salarios FROM depto WHERE codigo = @cod_depto)
			SET @salario = (SELECT salario FROM INSERTED)
		END
	ELSE
		BEGIN
			IF(@l_delete = 1)
				BEGIN
					SET @cod_depto = (SELECT depto FROM DELETED)
					SET @total = (SELECT total_salarios FROM depto WHERE codigo = @cod_depto)
					SET @salario = (SELECT salario FROM DELETED)
				END
		END
	
	IF(@salario IS NOT NULL)
		BEGIN
			IF(@total IS NOT NULL)
				BEGIN
					IF(@l_insert = 1 AND @l_delete = 0)
						BEGIN
							UPDATE depto
							SET total_salarios = total_salarios + (SELECT salario FROM INSERTED)
							WHERE codigo = @cod_depto
						END
					ELSE
						BEGIN
							IF(@l_insert = 0 AND @l_delete = 1)
								BEGIN
									UPDATE depto
									SET total_salarios = total_salarios - (SELECT salario FROM DELETED)
									WHERE codigo = @cod_depto
								END
							ELSE
								BEGIN
									IF(@l_insert = 1 AND @l_delete = 1)
										BEGIN
											IF((SELECT salario FROM DELETED) IS NOT NULL)
												BEGIN
													SET @dif = (SELECT salario FROM DELETED) - (SELECT salario FROM INSERTED)
													UPDATE depto
													SET total_salarios = total_salarios - @dif
													WHERE codigo = @cod_depto
												END
											ELSE
												BEGIN
													IF((SELECT salario FROM DELETED) IS NULL)
														BEGIN
															UPDATE depto
															SET total_salarios = total_salarios + (SELECT salario FROM INSERTED)
															WHERE codigo = @cod_depto
														END
												END
										END
								END
						END
				END
			ELSE
				BEGIN
					IF(@l_insert = 1)
						BEGIN
							UPDATE depto
							SET total_salarios = (SELECT salario FROM INSERTED)
							WHERE codigo = @cod_depto
						END
				END
		END
END	

INSERT INTO funcionario (id, nome, salario, depto) VALUES
(1, 'Fulano', 500.00, 1)

INSERT INTO funcionario (id, nome, salario, depto) VALUES
(2, 'Cicrano', 500.00, 1)

INSERT INTO funcionario (id, nome, salario, depto) VALUES
(3, 'Beltrano', 500.00, 1)

INSERT INTO funcionario (id, nome, salario, depto) VALUES
(4, 'Messi', 500.00, 2)

INSERT INTO funcionario (id, nome, salario, depto) VALUES
(5, 'Ronaldo', 990.00, 2)

INSERT INTO funcionario (id, nome, depto) VALUES
(6, 'Ibra', 2)

DELETE FROM funcionario
WHERE id = 1

UPDATE funcionario
SET salario = 100.00
WHERE id = 6

UPDATE funcionario
SET salario = 0.00
WHERE id = 3

SELECT * FROM funcionario
SELECT * FROM depto

