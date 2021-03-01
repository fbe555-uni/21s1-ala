from IPython.display import Latex
import operator

def LMatrix(mat, name=None, hidden=False):
    s = ''
    if name is not None and not hidden:
        s += '{} = '.format(name)
    s += r'\begin{pmatrix}'
    for r in mat:
        for e in r:
            s += r' {} &'.format(e)
        s = s[:-2] + r' \\'
    s = s[:-2] + r'\end{pmatrix}'
    if name is not None:
        globals()[name] = Matrix(mat)
    return s

def LScalarMul(mat, scalar, name=None):
    product = scalar*Matrix(mat)
    s = ''
    if name is not None:
        s += '{} = '.format(name)
    s += r'{} \cdot '.format(scalar)
    s += LMatrix(mat).data
    s += r' = \begin{pmatrix}'
    for r in mat:
        for e in r:
            s += r' {} \cdot {} &'.format(scalar, e)
        s = s[:-2] + r' \\'
    s = s[:-2] + r'\end{pmatrix} = ' + LMatrix(product).data 
    if name is not None:
        globals()[name] = product
    
    return Latex(s)

def LMatMul(mat1, mat2):
    mat1 = Matrix(mat1); mat2 = Matrix(mat2)
    s = LMatrix(mat1).data + r'\cdot' + LMatrix(mat2).data
    s += '=' + LMatrix([[''.join([r'{} \cdot {} + '.format(mat1[i,k], mat2[k,j]) 
                                  for k in range(mat1.ncols())])[:-3]
                        for j in range(mat2.ncols())]
                       for i in range(mat1.nrows())]).data
    s += '=' + LMatrix(mat1*mat2).data
    return Latex(s)

_operator_symbols = {'+': operator.add,
                     '-': operator.sub,
                     '/': operator.truediv,
                     '*': operator.mul}

def LElemWise(mat1, mat2, operator):
    s = LMatrix(mat1).data + str(operator) + LMatrix(mat2).data
    s += '= ' + LMatrix([['{} {} {}'.format(e1, operator, e2) 
                          for (e1, e2) in zip(r1, r2)] 
                         for (r1, r2) in zip(mat1, mat2)]).data
    s += '= ' + LMatrix(_operator_symbols[operator](Matrix(mat1), Matrix(mat2))).data
    return Latex(s)

def LCofactorDeterminant(mat, row=None, column=None, rhs_only=False):
    assert mat.is_square(), 'Matrix must be a square matrix for the determinant to be defined'
    
    if not rhs_only:
        s = r' \left| {} \right|  = '.format(LMatrix(mat))
    else:
        s = ''
        
    if mat.nrows() == 1:
        return str(mat[0,0])
    elif mat.nrows() == 2:
        return r'{} \cdot {} - {} \cdot {}'.format(mat[0,0], mat[1,1], mat[1, 0], mat[0, 1])
    
    assert row is not None or column is not None, 'If matrix is larger than 2 x 2, either row or column must be specified'
    
    rows = range(mat.nrows()) if row is None else [row]*mat.nrows()
    columns = range(mat.ncols()) if column is None else [column]*mat.ncols()
    
    s += ' '.join([r'{} \cdot \left| {} \right| + '
                   .format(mat[i, j], LMatrix(submatrix(mat, i, j)))
                   for i, j in zip(rows, columns) if mat[i, j] != 0])
    if mat.nrows() == 3:
        s = s[:-2] + '= '
        s += ' '.join([r'{} \cdot \left( {} \right) + '
                       .format(mat[i, j], LCofactorDeterminant(submatrix(mat, i, j), 
                                                               rhs_only=True))
                       for i, j in zip(rows, columns) if mat[i,j] != 0])
        s = s[:-2] + '= ' + str(mat.determinant()) + '   '
    return s[:-3]

def submatrix(mat, row, col):
    return mat.delete_rows([row]).delete_columns([col])

# def _LCofac_RHS(mat, row_col):
# def LFunction(name, 