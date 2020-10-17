class TagCloud():
    def __init__(self):
        self.tags = {}

    def add(self, tag):
        # typical dictionary is case sensitive and we don't want that here
        # so this custom type allows us to make something a little bit smarter
        # we are encapsulating the complexity
        # around the case sensitivity of tags
        # when using this class we no longer need to worry
        # about lower case or upper case characters
        # so our code is simpler and cleaner.
        # all that complexity is encapsulated in the TagCloud class
        self.tags[tag.lower()] = self.tags.get(tag.lower(), 0) + 1

    # implement magic method so we can get an item with subscripting
    # for a typical dictionary, it will throw an error if the item
    # we are trying to get doesn't exist
    def __getitem__(self, tag):
        return self.tags.get(tag.lower(), 0)

    # implement magic method to be able to set value for an item
    def __setitem__(self, tag, count):
        self.tags[tag.lower()] = count

    # implement magic method to get the length of an object of this class
    def __len__(self):
        return len(self.tags)

    # implement magic method to make the class iterable
    # all we have to do is to use one of the built in functions
    # to get an iterator object
    # an iterator objec is an object that walks a container
    # and gets one item at a time
    def __iter__(self):
        # this gives us one item of the tags at a time in a for loop
        return iter(self.tags)


cloud = TagCloud()
cloud.add("Python")
cloud.add("python")
cloud.add("python")

len(cloud)
cloud["python"] = 10
print(cloud["python"])

print(cloud.tags)
