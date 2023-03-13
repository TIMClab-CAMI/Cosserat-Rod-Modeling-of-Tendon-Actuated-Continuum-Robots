function M = Ad_g(R, r)

    M = [R zeros(3, 3); hat(r)*R R];

end
