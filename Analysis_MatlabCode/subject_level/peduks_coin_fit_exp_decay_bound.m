function [tau, A] = peduks_coin_fit_exp_decay_bound( betas, sampleOrder )
%Fits A * exp(t/tau) to the kernel
%weights. tau and A are inside fixed bounds via a penalty term
%(tau in [0.1, 20], A in [-5, 5]). 

tauBounds = [0.1, 20];
ABounds   = [-5, 5];

objective = @(p) sum((betas - p(1)*exp(sampleOrder/p(2))).^2) + ...
    1e6 * (max(0, tauBounds(1)-p(2)) + max(0, p(2)-tauBounds(2))) + ...
    1e6 * (max(0, ABounds(1)-p(1)) + max(0, p(1)-ABounds(2)));

p0 = [max(betas), 2];
p = fminsearch(objective, p0);

if p(2) < tauBounds(1) || p(2) > tauBounds(2)
    tau = NaN;
    A = NaN;
else
    A = p(1);
    tau = p(2);
end

end