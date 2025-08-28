# =============================
# Assignment 1: Design Your Own Class 
# =============================

# Parent Class
class Smartphone:
    def __init__(self, brand, model, battery):
        self.brand = brand
        self.model = model
        self.battery = battery   # battery in %

    def call(self, number):
        print(f"{self.brand} {self.model} is calling {number}...")

    def charge(self, amount):
        self.battery = min(100, self.battery + amount)
        print(f"{self.brand} {self.model} charged to {self.battery}%")

# Child Class (Inheritance + Encapsulation)
class GamingSmartphone(Smartphone):
    def __init__(self, brand, model, battery, cooling_system):
        # Inherit attributes from Smartphone using super()
        super().__init__(brand, model, battery)
        self.cooling_system = cooling_system

    # Extra method only for gaming smartphones
    def play_game(self, game):
        if self.battery > 20:
            print(f" Playing {game} on {self.brand} {self.model} with {self.cooling_system} cooling")
            self.battery -= 20
        else:
            print(" Battery too low to play games!")

# Test Assignment 1
print("\n--- Assignment 1: Smartphone Demo ---")
phone1 = Smartphone("Samsung", "S23", 50)
phone1.call("123-456-7890")
phone1.charge(30)

gaming_phone = GamingSmartphone("Asus", "ROG 7", 80, "liquid-cooling")
gaming_phone.play_game("PUBG")
gaming_phone.charge(10)


# =============================
# Activity 2: Polymorphism Challenge 
# =============================

class Car:
    def move(self):
        print(" Driving on the road")

class Plane:
    def move(self):
        print("Flying in the sky")

class Boat:
    def move(self):
        print("Sailing on the water")

# Test Activity 2
print("\n--- Activity 2: Polymorphism Demo ---")
vehicles = [Car(), Plane(), Boat()]
for v in vehicles:
    v.move()
