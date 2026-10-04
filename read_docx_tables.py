import docx

def extract_tables(filename):
    doc = docx.Document(filename)
    results = []
    for table in doc.tables:
        for row in table.rows:
            row_data = []
            for cell in row.cells:
                row_data.append(cell.text.strip())
            results.append(" | ".join(row_data))
    return '\n'.join(results)

try:
    text = extract_tables('SMP.docx')
    print("Table text length:", len(text))
    print("First 2000 chars:")
    print(text[:2000])
except Exception as e:
    print(e)
