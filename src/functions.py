from classes import *
from constants import *


def generate_items():
    items = []

    for i in range(ITEMS_AMOUNT):
        value = random.randint(MIN_VALUE, MAX_VALUE)
        weight = random.randint(MIN_WEIGHT, MAX_WEIGHT)

        item = Item(value, weight)

        items.append(item)

    return items


def greedy_method(items: list[Item]):
    backpack = Backpack()
    counter = 0

    while True:
        items_copy = items.copy()

        scout = [Scout(counter, items_copy[counter])]
        foragers_accumulation = define_foragers_accumulation(scout)

        if backpack.weight + items_copy[foragers_accumulation].weight > backpack.volume:
            break

        backpack.add_item(items_copy[foragers_accumulation])
        items_copy.pop(foragers_accumulation)

        counter += 1

    print(f"Greedy value: {backpack.value}.")
    save_data_to_file("greedy_method.txt", backpack)

    return backpack.value


def bee_colony_method(generated_items: list[Item], greedy_value: int):
    bee_colony_value = 0

    while bee_colony_value < greedy_value:
        items = generated_items.copy()
        backpack = Backpack()

        while True:
            scouts = spawn_scouts(items)
            foragers_accumulation = define_foragers_accumulation(scouts)

            if backpack.weight + items[foragers_accumulation].weight > backpack.volume:
                break

            backpack.add_item(items[foragers_accumulation])
            items.pop(foragers_accumulation)

        print(f"Artificial bee colony value: {backpack.value}.")
        save_data_to_file("bee_colony.txt", backpack)

        bee_colony_value = backpack.value

    return bee_colony_value


def define_foragers_accumulation(scouts: list[Scout]):
    foragers = spawn_foragers()

    information = collect_items_information(scouts)
    foragers_travel(foragers, scouts, information)

    foragers_accumulation = find_maximum_accumulated_item(foragers)

    return foragers_accumulation


def spawn_scouts(items: list[Item]):
    scouts = []
    occupied_positions = []

    # найменше значення серед кількістю розвідників і кількістю предметів
    # потрібно для того, щоб кількість розвідників не перевищувала кількість предметів
    smallest_value = SCOUTS_AMOUNT+1 if SCOUTS_AMOUNT+1 < len(items) else len(items)

    for i in range(smallest_value - 1):
        position = random.randint(0, len(items) - 1)

        while position in occupied_positions:
            position = random.randint(0, len(items) - 1)

        scout = Scout(position, items[position])

        scouts.append(scout)
        occupied_positions.append(position)

    return scouts


def spawn_foragers():
    foragers = []

    for i in range(FORAGERS_AMOUNT):
        forager = Forager(0)

        foragers.append(forager)

    return foragers


def collect_items_information(scouts: list[Scout]):
    information = [scout.collect_information() for scout in scouts]

    return information


def foragers_travel(foragers: list[Forager], scouts: list[Scout], information: list[int]):
    for forager in foragers:
        forager.travel_to_position(information, scouts)


def find_maximum_accumulated_item(foragers: list[Forager]):
    accumulation = {}

    for forager in foragers:
        if forager.position not in accumulation:
            accumulation[forager.position] = 1
        else:
            accumulation[forager.position] += 1

    return max(accumulation)


def save_data_to_file(file_name: str, backpack: Backpack):
    string_to_write = f'''Backpack value: {backpack.value}. 
Average item value: {round(backpack.value / len(backpack.items), 2)}
Average item weight: {round(backpack.weight / len(backpack.items), 2)}

Items in backpack:\n'''

    for item in backpack.items:
        string_to_write += str(item)

    with open(file_name, mode='w') as file:
        file.write(string_to_write)
