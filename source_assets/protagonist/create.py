"""Build the editable low-poly protagonist and export it for Godot."""

from pathlib import Path

import bpy
from mathutils import Vector


OUT = Path(__file__).resolve().parent
GAME_ASSET = OUT.parents[1] / "game" / "art" / "protagonist.glb"


def material(name: str, color: tuple[float, float, float], metallic: float = 0.0) -> bpy.types.Material:
    result = bpy.data.materials.new(name)
    result.diffuse_color = (*color, 1.0)
    result.use_nodes = True
    shader = result.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1.0)
    shader.inputs["Roughness"].default_value = 0.78
    shader.inputs["Metallic"].default_value = metallic
    result.use_backface_culling = False
    return result


SKIN = material("warm skin", (0.74, 0.43, 0.29))
HAIR = material("dark chestnut hair", (0.095, 0.043, 0.028))
HAIR_LIGHT = material("hair facets", (0.17, 0.075, 0.038))
CREAM = material("linen sleeves", (0.69, 0.56, 0.40))
NAVY = material("charcoal blue tunic", (0.055, 0.071, 0.105))
NAVY_LIGHT = material("tunic facets", (0.065, 0.075, 0.11))
RED = material("weathered red cloak", (0.24, 0.035, 0.04))
RED_LIGHT = material("cloak lit edge", (0.39, 0.085, 0.055))
TROUSERS = material("umber trousers", (0.14, 0.077, 0.052))
LEATHER = material("cognac leather", (0.27, 0.115, 0.045))
LEATHER_LIGHT = material("leather highlights", (0.39, 0.19, 0.078))
STEEL = material("brushed steel", (0.49, 0.55, 0.59), 0.55)
STEEL_EDGE = material("blade edge", (0.76, 0.72, 0.63), 0.45)
BRASS = material("aged brass", (0.49, 0.30, 0.08), 0.45)


def parent_keep(obj: bpy.types.Object, parent: bpy.types.Object) -> None:
    bpy.context.view_layer.update()
    transform = obj.matrix_world.copy()
    obj.parent = parent
    obj.matrix_world = transform


def pivot(name: str, location: tuple[float, float, float], parent: bpy.types.Object) -> bpy.types.Object:
    node = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(node)
    node.location = location
    parent_keep(node, parent)
    return node


def ico(name: str, position: tuple[float, float, float], scale: tuple[float, float, float], mat: bpy.types.Material, parent: bpy.types.Object, subdivision: int = 1) -> bpy.types.Object:
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivision, radius=1, location=position)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    obj.data.materials.append(mat)
    parent_keep(obj, parent)
    return obj


def box(name: str, position: tuple[float, float, float], size: tuple[float, float, float], mat: bpy.types.Material, parent: bpy.types.Object, bevel: float = 0.0) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cube_add(size=1, location=position)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        modifier = obj.modifiers.new("small hard edges", "BEVEL")
        modifier.width = bevel
        modifier.segments = 1
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=modifier.name)
    obj.data.materials.append(mat)
    parent_keep(obj, parent)
    return obj


def segment(name: str, start: tuple[float, float, float], end: tuple[float, float, float], radii: tuple[float, float], mat: bpy.types.Material, parent: bpy.types.Object, sides: int = 6) -> bpy.types.Object:
    a, b = Vector(start), Vector(end)
    direction = b - a
    bpy.ops.mesh.primitive_cone_add(vertices=sides, radius1=radii[1], radius2=radii[0], depth=direction.length, location=(a + b) / 2)
    obj = bpy.context.object
    obj.name = name
    obj.rotation_euler = direction.to_track_quat("Z", "Y").to_euler()
    obj.data.materials.append(mat)
    parent_keep(obj, parent)
    return obj


def cloth(name: str, vertices: list[tuple[float, float, float]], faces: list[tuple[int, ...]], mats: list[bpy.types.Material], parent: bpy.types.Object) -> bpy.types.Object:
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.clear()
    for mat in mats:
        mesh.materials.append(mat)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    for index, polygon in enumerate(mesh.polygons):
        polygon.material_index = index % len(mats)
    parent_keep(obj, parent)
    return obj


def build_body(root: bpy.types.Object) -> None:
    ico("torso", (0, 0.005, 1.24), (0.32, 0.19, 0.35), NAVY, root)
    segment("neck", (0, 0, 1.49), (0, 0, 1.59), (0.09, 0.085), SKIN, root)
    ico("head", (0, -0.005, 1.70), (0.17, 0.16, 0.21), SKIN, root, 2)
    ico("hair crown", (0, 0.045, 1.80), (0.19, 0.17, 0.15), HAIR, root, 1)
    ico("hair side sweep", (-0.075, -0.09, 1.81), (0.14, 0.10, 0.07), HAIR_LIGHT, root)
    ico("low bun", (0.13, 0.15, 1.70), (0.145, 0.13, 0.12), HAIR, root)
    ico("bun light facet", (0.15, 0.24, 1.72), (0.10, 0.045, 0.07), HAIR_LIGHT, root)
    segment("side lock", (-0.15, -0.10, 1.78), (-0.20, -0.08, 1.58), (0.033, 0.008), HAIR, root, 5)
    box("belt", (0, 0.015, 1.03), (0.67, 0.42, 0.09), LEATHER, root, 0.025)
    box("belt buckle", (0, -0.208, 1.035), (0.12, 0.025, 0.10), BRASS, root, 0.01)
    box("satchel", (0.34, 0.07, 0.91), (0.23, 0.15, 0.25), LEATHER, root, 0.025)
    box("satchel flap", (0.34, -0.02, 1.01), (0.25, 0.035, 0.09), LEATHER_LIGHT, root)
    cloth("split tunic tails", [(-.31,-.12,1.02),(.31,-.12,1.02),(-.38,-.15,.74),(-.08,-.17,.72),(.07,-.16,.74),(.38,-.15,.77),(-.30,.16,1.02),(.30,.16,1.02),(-.40,.20,.69),(-.07,.23,.73),(.10,.23,.71),(.40,.20,.76)], [(0,3,2),(0,1,4,3),(1,5,4),(6,8,9),(6,7,10,9),(7,11,10)], [NAVY, NAVY_LIGHT], root)
    cloth("red shoulder mantle", [(-.38,-.04,1.50),(.37,-.04,1.50),(-.43,.21,1.46),(.40,.21,1.45),(-.27,.31,1.19),(.32,.30,1.21),(.04,.37,1.34),(-.29,.26,1.04)], [(0,1,3,6,2),(2,6,4),(6,3,5,4),(4,5,7)], [RED, RED_LIGHT], root)
    cloth("cloak tail", [(-.27,.29,1.24),(.08,.34,1.19),(-.44,.38,1.04),(-.55,.42,.97),(-.64,.45,.94),(-.75,.47,.83),(-.85,.45,.69),(-.86,.44,.56),(-.70,.42,.63),(-.56,.39,.78)], [(0,1,2),(1,3,2),(1,4,3),(3,4,9),(4,5,9),(5,6,8,9),(6,7,8)], [RED, RED_LIGHT], root)
    cloth("linen side flap", [(.20,.18,1.02),(.35,.19,1.02),(.39,.20,.78),(.08,.20,.79)], [(0,1,2,3)], [CREAM], root)


def build_leg(side: int, root: bpy.types.Object) -> None:
    sign = float(side)
    name = "Leg_L" if side > 0 else "Leg_R"
    x = sign * .18
    leg = pivot(name, (x, 0, .94), root)
    knee_x = x + sign * .12
    ankle_x = x + sign * .22
    segment(name + " thigh", (x, 0, .94), (knee_x, -.025, .52), (.16, .135), TROUSERS, leg)
    ico(name + " knee fold", (knee_x, -.025, .53), (.14, .13, .09), TROUSERS, leg)
    segment(name + " shin", (knee_x, -.025, .52), (ankle_x, -.015, .17), (.125, .10), LEATHER, leg)
    segment(name + " cuff", (knee_x + sign*.015, -.025, .42), (knee_x + sign*.035, -.025, .32), (.15, .145), LEATHER_LIGHT, leg)
    box(name + " boot", (ankle_x, -.07, .095), (.23, .34, .18), LEATHER, leg, .03)
    box(name + " sole", (ankle_x, -.085, .025), (.25, .36, .05), LEATHER_LIGHT, leg, .01)


def build_arm(side: int, root: bpy.types.Object) -> bpy.types.Object:
    sign = float(side)
    name = "Arm_L" if side > 0 else "Arm_R"
    shoulder = (sign*.38, 0, 1.43)
    elbow = (sign*.47, -.02, 1.14)
    hand = (sign*.50, -.075, .93)
    arm = pivot(name, shoulder, root)
    segment(name + " linen sleeve", shoulder, elbow, (.15, .12), CREAM, arm, 5)
    segment(name + " forearm", elbow, hand, (.095, .065), SKIN, arm, 6)
    ico(name + " hand", hand, (.065, .06, .085), SKIN, arm)
    return arm


def build_sword(arm: bpy.types.Object) -> None:
    # The sword stays in the right hand as the arm swings or attacks.
    pommel = (.53, -.13, 1.00)
    guard = (.46, -.05, .79)
    tip = (1.12, -.16, .10)
    segment("wood grip", pommel, guard, (.035, .03), LEATHER, arm, 6)
    ico("pommel", pommel, (.055, .055, .06), BRASS, arm)
    segment("cross guard", (.30,-.05,.79), (.62,-.05,.79), (.028,.028), BRASS, arm, 4)
    cloth("tapered sword blade", [(.38,.04,.77),(.56,-.08,.77),(1.12,-.16,.10),(.46,-.02,.77),(1.13,-.16,.10)], [(0,1,2),(3,0,4)], [STEEL, STEEL_EDGE], arm)
    segment("blade spine", guard, tip, (.018, .002), STEEL, arm, 4)


def main() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    root = bpy.data.objects.new("Protagonist", None)
    bpy.context.collection.objects.link(root)
    build_body(root)
    build_leg(-1, root)
    build_leg(1, root)
    build_arm(-1, root)
    sword_arm = build_arm(1, root)
    build_sword(sword_arm)
    bpy.context.preferences.filepaths.save_version = 0
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT / "protagonist.blend"))
    bpy.ops.export_scene.gltf(filepath=str(GAME_ASSET), export_format="GLB")


if __name__ == "__main__":
    main()
