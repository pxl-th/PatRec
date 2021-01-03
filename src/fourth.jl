function sudoku(initial_solution)
    model = Model(ConstraintSolver.Optimizer)
    # grid(i, j, k) = 1 iff cell (i, j) has number k.
    @variable(model, grid[x=1:9, y=1:9, k=1:9], Bin)
    for i in 1:9, j in 1:9
        # only one number per cell is allowed.
        @constraint(model, sum(grid[i, j, k] for k in 1:9) == 1)
    end
    for i in 1:9, k in 1:9
        # sum across column (j) for fixed (k) - row constraint.
        # numbers in a row do not repeat.
        @constraint(model, sum(grid[i, j, k] for j in 1:9) == 1)
        # sum across row (j) - column constraint.
        # numbers in a column do not repeat.
        @constraint(model, sum(grid[j, i, k] for j in 1:9) == 1)
    end
    for i in 1:3:7, j in 1:3:7, k in 1:9
        # each number in a 3x3 sub-grid appears only once.
        @constraint(model, sum(grid[r, c, k] for r in i:i+2, c in j:j+2) == 1)
    end
    # add initial solution as constraints.
    for i in 1:9, j in 1:9
        initial_solution[i, j] == 0 && continue
        @constraint(model, sum(grid[i, j, initial_solution[i, j]]) == 1)
    end

    optimize!(model)
    solution = value.(grid)
    solution_grid = zeros(Int, 9, 9)
    for i in 1:9, j in 1:9, k in 1:9
        round(solution[i, j, k]) == 1 && (solution_grid[i, j] = k;)
    end

    solution_grid
end
