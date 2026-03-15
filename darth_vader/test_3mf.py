#!/usr/bin/env python3
"""
TDD tests for the Darth Vader Challenge Coin 3MF builder.

Verifies Bambu Studio-native 3MF structure and Darth Vader-specific colors.
"""
import json
import os
import sys
import zipfile
import xml.etree.ElementTree as ET
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from create_3mf import parse_stl, make_mesh_xml, create_bambu_3mf

BUILD_DIR = os.path.join(os.path.dirname(__file__), "build")

NS = {
    "m": "http://schemas.microsoft.com/3dmanufacturing/core/2015/02",
    "p": "http://schemas.microsoft.com/3dmanufacturing/production/2015/06",
}

TEST_3MF = os.path.join(BUILD_DIR, "test_output.3mf")
TEST_COLORS = [
    {"name": "Black",           "hex": "#1A1A1A", "stl": "coin_black", "extruder": 1},
    {"name": "Starbucks Gold",  "hex": "#CBA258", "stl": "coin_gold",  "extruder": 2},
    {"name": "Starbucks Green", "hex": "#00704A", "stl": "coin_green", "extruder": 3},
    {"name": "White",           "hex": "#FFFFFF", "stl": "coin_white", "extruder": 4},
]


def setUpModule():
    create_bambu_3mf(TEST_3MF, TEST_COLORS)


def tearDownModule():
    if os.path.exists(TEST_3MF):
        os.remove(TEST_3MF)


class TestArchiveStructure(unittest.TestCase):
    def setUp(self):
        self.zf = zipfile.ZipFile(TEST_3MF)

    def tearDown(self):
        self.zf.close()

    def test_required_files_present(self):
        names = self.zf.namelist()
        self.assertIn("[Content_Types].xml", names)
        self.assertIn("_rels/.rels", names)
        self.assertIn("3D/3dmodel.model", names)
        self.assertIn("3D/Objects/object_1.model", names)
        self.assertIn("3D/_rels/3dmodel.model.rels", names)
        self.assertIn("Metadata/model_settings.config", names)
        self.assertIn("Metadata/project_settings.config", names)

    def test_sub_model_file_exists(self):
        self.assertIn("3D/Objects/object_1.model", self.zf.namelist())


class TestRootModelStructure(unittest.TestCase):
    def setUp(self):
        with zipfile.ZipFile(TEST_3MF) as zf:
            self.root = ET.fromstring(zf.read("3D/3dmodel.model"))

    def _objects(self):
        return self.root.findall(".//m:object", NS)

    def test_no_inline_mesh_objects_in_root(self):
        mesh_objects = [o for o in self._objects() if o.find("m:mesh", NS) is not None]
        self.assertEqual(len(mesh_objects), 0)

    def test_assembly_object_with_four_components(self):
        assembly_objects = [o for o in self._objects() if o.find("m:components", NS) is not None]
        self.assertEqual(len(assembly_objects), 1)
        components = assembly_objects[0].findall("m:components/m:component", NS)
        self.assertEqual(len(components), 4)

    def test_components_reference_sub_model_via_path(self):
        assembly = [o for o in self._objects() if o.find("m:components", NS) is not None][0]
        for comp in assembly.findall("m:components/m:component", NS):
            path = comp.get("{http://schemas.microsoft.com/3dmanufacturing/production/2015/06}path")
            self.assertEqual(path, "/3D/Objects/object_1.model")

    def test_single_build_item(self):
        build_items = self.root.findall(".//m:build/m:item", NS)
        self.assertEqual(len(build_items), 1)


class TestSubModelStructure(unittest.TestCase):
    def setUp(self):
        with zipfile.ZipFile(TEST_3MF) as zf:
            self.sub = ET.fromstring(zf.read("3D/Objects/object_1.model"))

    def _objects(self):
        return self.sub.findall(".//m:object", NS)

    def test_four_mesh_objects_in_sub_model(self):
        mesh_objects = [o for o in self._objects() if o.find("m:mesh", NS) is not None]
        self.assertEqual(len(mesh_objects), 4)

    def test_each_mesh_has_vertices_and_triangles(self):
        for obj in self._objects():
            mesh = obj.find("m:mesh", NS)
            if mesh is None:
                continue
            self.assertIsNotNone(mesh.find("m:vertices", NS))
            self.assertIsNotNone(mesh.find("m:triangles", NS))


class TestExtruderAssignments(unittest.TestCase):
    def setUp(self):
        with zipfile.ZipFile(TEST_3MF) as zf:
            self.config = ET.fromstring(zf.read("Metadata/model_settings.config"))

    def _parts(self):
        return self.config.findall(".//part")

    def test_four_parts_defined(self):
        self.assertEqual(len(self._parts()), 4)

    def test_extruder_slots_are_1_through_4(self):
        extruders = sorted(
            int(p.find("metadata[@key='extruder']").get("value"))
            for p in self._parts()
        )
        self.assertEqual(extruders, [1, 2, 3, 4])

    def test_each_color_has_correct_extruder(self):
        assignments = {
            p.find("metadata[@key='name']").get("value"):
            int(p.find("metadata[@key='extruder']").get("value"))
            for p in self._parts()
        }
        self.assertEqual(assignments["Black"], 1)
        self.assertEqual(assignments["Starbucks Gold"], 2)
        self.assertEqual(assignments["Starbucks Green"], 3)
        self.assertEqual(assignments["White"], 4)


class TestFilamentColors(unittest.TestCase):
    def setUp(self):
        with zipfile.ZipFile(TEST_3MF) as zf:
            self.config = json.loads(zf.read("Metadata/project_settings.config"))

    def test_four_filament_colors_defined(self):
        self.assertEqual(len(self.config["filament_colour"]), 4)

    def test_black_is_slot_1(self):
        self.assertEqual(self.config["filament_colour"][0], "#1A1A1A")

    def test_starbucks_gold_is_slot_2(self):
        self.assertEqual(self.config["filament_colour"][1], "#CBA258")

    def test_starbucks_green_is_slot_3(self):
        self.assertEqual(self.config["filament_colour"][2], "#00704A")

    def test_white_is_slot_4(self):
        self.assertEqual(self.config["filament_colour"][3], "#FFFFFF")


class TestMeshGeneration(unittest.TestCase):
    def test_mesh_xml_has_vertices_and_triangles(self):
        tris = parse_stl(os.path.join(BUILD_DIR, "coin_black.stl"))
        xml_str, face_count = make_mesh_xml(1, "test-uuid", tris)
        wrapped = (
            '<root xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02"'
            ' xmlns:p="http://schemas.microsoft.com/3dmanufacturing/production/2015/06">'
            + xml_str + '</root>'
        )
        root = ET.fromstring(wrapped)
        obj = root.find("m:object", NS)
        self.assertIsNotNone(obj.find("m:mesh/m:vertices", NS))
        self.assertIsNotNone(obj.find("m:mesh/m:triangles", NS))
        self.assertGreater(face_count, 0)

    def test_face_count_matches_triangle_count(self):
        tris = parse_stl(os.path.join(BUILD_DIR, "coin_black.stl"))
        _, face_count = make_mesh_xml(1, "test-uuid", tris)
        self.assertEqual(face_count, len(tris))


if __name__ == "__main__":
    unittest.main(verbosity=2)
