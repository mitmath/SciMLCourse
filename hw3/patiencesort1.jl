function patiencesort1(p)
    # p : Permutation
    # Returns length of longest increasing subsequence
    pile_tops = Int[]
    for α ∈ p       
        whichpile = 1+sum(α.>pile_tops) # first pile where α is smaller
        if  whichpile ≤ length(pile_tops)
            pile_tops[whichpile] = α   # put α on top of a pile  or ..
        else
            push!(pile_tops, α)        # create a new pile
        end
    end
    return length(pile_tops)
end