import unittest

from functions import greedy_method, bee_colony_method, generate_items


class TestBeeAlgorithm(unittest.TestCase):
    def test_bee_colony_algorithm(self):
        # arrange
        items = generate_items()

        # act
        greedy_value = greedy_method(items)
        bee_colony_value = bee_colony_method(items, greedy_value)

        # assert
        self.assertGreaterEqual(bee_colony_value, greedy_value)
