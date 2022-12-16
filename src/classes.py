import random


class Item:
    def __init__(self, value: int, weight: int):
        self.value = value
        self.weight = weight

    def __str__(self):
        return f"Item - value: {self.value}, weight: {self.weight}\n"

    def get_nectar_amount(self):
        return self.value / self.weight


class Backpack:
    def __init__(self):
        self.volume = 500
        self.weight = 0
        self.value = 0
        self.items = []

    def add_item(self, item: Item):
        if self.weight + item.weight <= self.volume:
            self.items.append(item)
            self.value += item.value
            self.weight += item.weight


class Bee:
    def __init__(self, position: int):
        self.position = position


class Scout(Bee):
    def __init__(self, position: int, item: Item):
        super().__init__(position)
        self.explored_item = item

    def collect_information(self):
        return self.explored_item.get_nectar_amount()


class Forager(Bee):
    def travel_to_position(self, information: list[int], scouts: list[Scout]):
        # визначаємо куди летіти за допомогою дискретної величини
        discrete_quantity = []
        discrete_quantity_sum = 0

        for i in range(len(information)):
            discrete_quantity_sum += information[i]
            discrete_quantity.append(discrete_quantity_sum)

        random_number = random.uniform(0, discrete_quantity[len(discrete_quantity) - 1])

        for i in range(len(discrete_quantity)):
            if i == 0:
                if random_number < discrete_quantity[i]:
                    self.position = scouts[i].position
                    break
            else:
                if discrete_quantity[i - 1] < random_number <= discrete_quantity[i]:
                    self.position = scouts[i].position
                    break
