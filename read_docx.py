import docx

def extract_text(filename):
    doc = docx.Document(filename)
    full_text = []
    for para in doc.paragraphs:
        full_text.append(para.text)
    return '\n'.join(full_text)

try:
    text = extract_text('SMP.docx')
    print("Document length:", len(text))
    print("First 1000 chars:")
    print(text[:1000])
except Exception as e:
    print(e)
