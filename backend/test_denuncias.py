from denuncias import listar_denuncias, obtener_denuncia_por_id


def test_listar_denuncias():
    datos = [
        {
            "id": 1,
            "titulo": "Robo",
            "localizacion": "Centro",
            "nombre": "Juan",
            "descripcion": "Robo en la calle"
        }
    ]

    resultado = listar_denuncias(datos)

    assert len(resultado) == 1
    assert resultado[0]["titulo"] == "Robo"


def test_obtener_denuncia_con_nombre():
    datos = [
        {
            "id": 1,
            "titulo": "Accidente",
            "localizacion": "Avenida",
            "nombre": "Maria",
            "descripcion": "Choque"
        }
    ]

    resultado = obtener_denuncia_por_id(datos, 1)

    assert resultado["nombre"] == "Maria"


def test_obtener_denuncia_sin_nombre():
    datos = [
        {
            "id": 2,
            "titulo": "Incendio",
            "localizacion": "Barrio",
            "descripcion": "Fuego en casa"
        }
    ]

    resultado = obtener_denuncia_por_id(datos, 2)

    assert resultado["nombre"] == "Anonimo"