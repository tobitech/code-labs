from abc import ABC, abstractmethod


class UIControl(ABC):
    @abstractmethod
    def draw(self):
        pass


class TextBox(UIControl):
    def draw(self):
        print("TextBox")


class DropDownList(UIControl):
    def draw(self):
        print("DropDownList")


# def draw(control):
#     control.draw()

def draw(controls):
    for control in controls:
        control.draw()


ddl = DropDownList()
textbox = TextBox()
# print(isinstance(ddl, UIControl))
# draw(ddl)  # returns DropDownList
# draw(textbox)  # returns TextBox

draw([ddl, textbox])  # returns `DropDownList TextBox`
