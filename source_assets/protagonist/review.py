"""Render the editable protagonist from the reference's rear three-quarter view."""

import sys

import bpy
from mathutils import Vector


def point_at(obj: bpy.types.Object, target: Vector) -> None:
    obj.rotation_euler = (target - obj.location).to_track_quat("-Z", "Y").to_euler()


def main() -> None:
    scene = bpy.context.scene
    camera_data = bpy.data.cameras.new("Review camera")
    camera = bpy.data.objects.new("Review camera", camera_data)
    scene.collection.objects.link(camera)
    camera.location = (3.5, 6.0, 1.5)
    point_at(camera, Vector((0.0, 0.0, 1.05)))
    camera_data.type = "ORTHO"
    camera_data.ortho_scale = 3.1
    scene.camera = camera

    light_data = bpy.data.lights.new("Review key", "AREA")
    light = bpy.data.objects.new("Review key", light_data)
    scene.collection.objects.link(light)
    light.location = (-3.0, 2.0, 5.0)
    light_data.energy = 500
    light_data.shape = "DISK"
    light_data.size = 5.0
    point_at(light, Vector((0.0, 0.0, 1.0)))

    scene.render.engine = "CYCLES"
    scene.cycles.samples = 16
    scene.render.resolution_x = 768
    scene.render.resolution_y = 1024
    scene.render.resolution_percentage = 100
    scene.world.color = (0.3, 0.25, 0.23)
    scene.render.image_settings.file_format = "PNG"
    scene.render.filepath = sys.argv[-1]
    bpy.ops.render.render(write_still=True)


if __name__ == "__main__":
    main()
