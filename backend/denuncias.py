def listar_denuncias(denuncias):
    """
    Retorna todas las denuncias
    """
    return denuncias


def obtener_denuncia_por_id(denuncias, id):
    """
    Busca una denuncia por ID y asegura nombre por defecto
    """
    for d in denuncias:
        if d["id"] == id:
            # Si no tiene nombre, asigna "Anonimo"
            if not d.get("nombre"):
                d["nombre"] = "Anonimo"
            return d
    return None