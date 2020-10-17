class TagCloud():
    def __init__(self):
        # add two underscores to make tags private
        self.__tags = {}

    def add(self, tag):
        self.tags[tag.lower()] = self.__tags.get(tag.lower(), 0) + 1

    def __getitem__(self, tag):
        return self.__tags.get(tag.lower(), 0)

    def __setitem__(self, tag, count):
        self.__tags[tag.lower()] = count

    def __len__(self):
        return len(self.__tags)

    def __iter__(self):
        return iter(self.__tags)


cloud = TagCloud()
# cloud.add("python")
# cloud.add("python")
# cloud.add("Python")

# this works perfectly
# print(cloud["PYTHON"])

# this throws an exception;
# if we try to access the underlying dictionary in our custom class
# print(cloud.__tags["PYTHON"])

# print(cloud.__tags)  # returns AttributeError since it's not private

# but you can somehow still access private attributes
# every class has a __dict__
# that gives you a dictionary of all the attributes in the class
print(cloud.__dict__)  # returns `{'_TagCloud__tags': {}}`
print(cloud._TagCloud__tags)  # returns {}
