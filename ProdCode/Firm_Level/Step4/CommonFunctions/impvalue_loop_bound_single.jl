function impvalue_loop_bound_single(eqval::Float64, debt::Float64, r::Float64, sig::Float64, T_t::Real)
    # eqval: market cap
    # debt: weighted average of liability
    # r: interest rate
    # sig: volitility
    # t: maturity

    BI_EPS = 0.1
    tol = 1e-6
    maxiter_newton = 10 # max iterations for Newton's method
    maxiter_bisection = 100 # max iterations for bisection method


    if isnan(eqval)
        av_final = NaN
        Nd1_final = NaN
    else
        # precompute fixed values
        rsigsq = (r + sig^2.0/2.0)*T_t
        sigsqrtt = sig * sqrt(T_t)
        discfact = exp(-r*T_t)

        #initialize upper and lower bounds using theoretical results, refer to the document "The Underlying Asset Value
        # Bounded by its Call Option Value" by Prof Duan for details
        tb_upper = eqval+discfact*debt
        d2 = (log(eqval/debt) + rsigsq)/sigsqrtt - sigsqrtt
        tb_lower = eqval+discfact*debt*normcdf(d2)

        # Quick refinement to the lower or upper bounds:
        # The objective is to refine the lower bound in cases where the asset
        # value is close to the theoretical upper bound. If strick price is smaller
        # than lower bound, proceed to newton method without any refinement. Otherwise, calculate
        # the equity value using some starting price as the asset value. The starting price could be the
        # strike price, 0.9*upper_bound or the mid-point depending on the relative position of the strike price and bounds.
        # Compare the calculated equity value with data and determine whether upper or lower bound
        # should be replaced by the starting price. If lower bound gets replaced, proceed to newton method. If upper bound
        # gets replaced, scale down the starting price by 0.9 and redo the calculation and
        # replacement if the scaled-down price is still above the lower bound.

        f_tmp = debt
        if f_tmp > tb_lower
            if f_tmp >= tb_upper
                f_tmp = 0.9*tb_upper
                if f_tmp <= tb_lower
                    f_tmp = 0.5*(tb_upper + tb_lower)
                end
            end

            for fi = 1:2
                d = (log(f_tmp/debt) + rsigsq)/sigsqrtt
                Nd1 = normcdf(d)
                d_sig = normcdf(d - sigsqrtt)

                fv = f_tmp * Nd1 - discfact * debt * d_sig

                zz = float(fv > eqval)
                if zz == 1
                    tb_upper = f_tmp
                    f_tmp = 0.9*f_tmp
                    if f_tmp < tb_lower
                        break
                    end
                else
                    tb_lower = f_tmp
                    break
                end
            end
        end

        av = (tb_upper + tb_lower)/2.0

        newton_succeed = 0 # Newton's method
        for iter = 1:maxiter_newton
            d1 = (log(av/debt) + rsigsq)/sigsqrtt
            d2 = d1 - sigsqrtt

            # compute f'(av)
            Nd1 = normcdf(d1)
            Nd2 = normcdf(d2)

            fv = av * Nd1 - discfact * debt * Nd2
            # compute the step to take from av
            av_step = -(fv - eqval) / Nd1

            if av_step == Inf
                break
            end

            if abs(av_step/av) < tol
                av_final = av
                Nd1_final = Nd1
                newton_succeed = 1
                break
            else
                av = av + av_step
            end
        end

        if newton_succeed == 0  # If Newton's method fails, switch to bi-section method
            d_upper = tb_upper
            d_lower = tb_lower

            counter = 0
            for iter = 1:maxiter_bisection
                counter+=1
                # println("bisection")
                av = (d_upper + d_lower)/2.0

                # @printf("current_iter = %d, maxiter = %.3f, equity = %.3f, debt = %.3f, rf = %.3f, sig = %.3f, av = %.3f, upper = %.3f, lower = %.3f \n",
                # iter, maxiter_bisection, eqval, debt, r, sig, av, d_upper, d_lower)

                d = (log(av/debt) + rsigsq)/sigsqrtt

                Nd1 = normcdf(d)
                d_sig = normcdf(d - sigsqrtt)

                fv = av * Nd1 - discfact * debt * d_sig

                zz = float(fv > eqval)

                d_upper = zz * av + (1.0 - zz) * d_upper
                d_lower = zz * d_lower + (1.0 - zz) * av

                if (d_upper/d_lower-1) <= tol
                    av = (d_upper + d_lower) /2.0
                    av_final = av
                    Nd1_final = Nd1
                    break
                end
            end

            if counter == maxiter_bisection
                println("maximum iteration for bisection reached")
            end
        end
    end

    return av_final, Nd1_final
end
