import PyPDF2

# manipulating PDFs demo
# with open("first.pdf", "rb") as file:
#     reader = PyPDF2.PdfFileReader(file)
#     # returns the number of pages in your PDF
#     print(reader.numPages)
#     # getPage is 0 based index
#     page = reader.getPage(0)
#     # this doesn't modify the original PDF,
#     # it's only rotating the page object in memory
#     page.rotateClockwise(90)
#     # so we need to write it to a separate PDF file
#     writer = PyPDF2.PdfFileWriter()
#     writer.addPage(page)
#     # `wb` means write binary
#     with open("rotated.pdf", "wb") as output:
#         writer.write(output)

# merging PDFs demo:
merger = PyPDF2.PdfFileMerger()

# in a real world app, you will iterate through all the PDFs in a directory
file_names = ["first.pdf", "second.pdf"]
for file_name in file_names:
    merger.append(file_name)

merger.write("combined.pdf")
