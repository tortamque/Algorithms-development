from functions import generate_items, greedy_method, bee_colony_method
from classes import Backpack

backpack = Backpack()

# генеруємо предмети
items = generate_items()

# вирішуємо задачу жадібним алгоритмом
greedy_value = greedy_method(items)

# вирішуємо задачу бджолиним алгоритмом
bee_colony_method(items, greedy_value)
