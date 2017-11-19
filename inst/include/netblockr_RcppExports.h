// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#ifndef RCPP_netblockr_RCPPEXPORTS_H_GEN_
#define RCPP_netblockr_RCPPEXPORTS_H_GEN_

#include <Rcpp.h>

namespace netblockr {

    using namespace Rcpp;

    namespace {
        void validateSignature(const char* sig) {
            Rcpp::Function require = Rcpp::Environment::base_env()["require"];
            require("netblockr", Rcpp::Named("quietly") = true);
            typedef int(*Ptr_validate)(const char*);
            static Ptr_validate p_validate = (Ptr_validate)
                R_GetCCallable("netblockr", "_netblockr_RcppExport_validate");
            if (!p_validate(sig)) {
                throw Rcpp::function_not_exported(
                    "C++ function with signature '" + std::string(sig) + "' not found in netblockr");
            }
        }
    }

    inline XPtr< nbTable > nbBuildNetblockTable(CharacterVector BaseAndMask, CharacterVector IPaddrStrings, IntegerVector Mask, CharacterVector Description) {
        typedef SEXP(*Ptr_nbBuildNetblockTable)(SEXP,SEXP,SEXP,SEXP);
        static Ptr_nbBuildNetblockTable p_nbBuildNetblockTable = NULL;
        if (p_nbBuildNetblockTable == NULL) {
            validateSignature("XPtr< nbTable >(*nbBuildNetblockTable)(CharacterVector,CharacterVector,IntegerVector,CharacterVector)");
            p_nbBuildNetblockTable = (Ptr_nbBuildNetblockTable)R_GetCCallable("netblockr", "_netblockr_nbBuildNetblockTable");
        }
        RObject rcpp_result_gen;
        {
            RNGScope RCPP_rngScope_gen;
            rcpp_result_gen = p_nbBuildNetblockTable(Shield<SEXP>(Rcpp::wrap(BaseAndMask)), Shield<SEXP>(Rcpp::wrap(IPaddrStrings)), Shield<SEXP>(Rcpp::wrap(Mask)), Shield<SEXP>(Rcpp::wrap(Description)));
        }
        if (rcpp_result_gen.inherits("interrupted-error"))
            throw Rcpp::internal::InterruptedException();
        if (rcpp_result_gen.inherits("try-error"))
            throw Rcpp::exception(as<std::string>(rcpp_result_gen).c_str());
        return Rcpp::as<XPtr< nbTable > >(rcpp_result_gen);
    }

    inline void nbSetMaskOrder(XPtr< nbTable > nbt, IntegerVector Masks) {
        typedef SEXP(*Ptr_nbSetMaskOrder)(SEXP,SEXP);
        static Ptr_nbSetMaskOrder p_nbSetMaskOrder = NULL;
        if (p_nbSetMaskOrder == NULL) {
            validateSignature("void(*nbSetMaskOrder)(XPtr< nbTable >,IntegerVector)");
            p_nbSetMaskOrder = (Ptr_nbSetMaskOrder)R_GetCCallable("netblockr", "_netblockr_nbSetMaskOrder");
        }
        RObject rcpp_result_gen;
        {
            RNGScope RCPP_rngScope_gen;
            rcpp_result_gen = p_nbSetMaskOrder(Shield<SEXP>(Rcpp::wrap(nbt)), Shield<SEXP>(Rcpp::wrap(Masks)));
        }
        if (rcpp_result_gen.inherits("interrupted-error"))
            throw Rcpp::internal::InterruptedException();
        if (rcpp_result_gen.inherits("try-error"))
            throw Rcpp::exception(as<std::string>(rcpp_result_gen).c_str());
    }

    inline DataFrame nbGetNetblockTable(XPtr< nbTable > nbt) {
        typedef SEXP(*Ptr_nbGetNetblockTable)(SEXP);
        static Ptr_nbGetNetblockTable p_nbGetNetblockTable = NULL;
        if (p_nbGetNetblockTable == NULL) {
            validateSignature("DataFrame(*nbGetNetblockTable)(XPtr< nbTable >)");
            p_nbGetNetblockTable = (Ptr_nbGetNetblockTable)R_GetCCallable("netblockr", "_netblockr_nbGetNetblockTable");
        }
        RObject rcpp_result_gen;
        {
            RNGScope RCPP_rngScope_gen;
            rcpp_result_gen = p_nbGetNetblockTable(Shield<SEXP>(Rcpp::wrap(nbt)));
        }
        if (rcpp_result_gen.inherits("interrupted-error"))
            throw Rcpp::internal::InterruptedException();
        if (rcpp_result_gen.inherits("try-error"))
            throw Rcpp::exception(as<std::string>(rcpp_result_gen).c_str());
        return Rcpp::as<DataFrame >(rcpp_result_gen);
    }

    inline DataFrame nbLookupIPaddrs(XPtr< nbTable > nbt, CharacterVector IPaddrStrings) {
        typedef SEXP(*Ptr_nbLookupIPaddrs)(SEXP,SEXP);
        static Ptr_nbLookupIPaddrs p_nbLookupIPaddrs = NULL;
        if (p_nbLookupIPaddrs == NULL) {
            validateSignature("DataFrame(*nbLookupIPaddrs)(XPtr< nbTable >,CharacterVector)");
            p_nbLookupIPaddrs = (Ptr_nbLookupIPaddrs)R_GetCCallable("netblockr", "_netblockr_nbLookupIPaddrs");
        }
        RObject rcpp_result_gen;
        {
            RNGScope RCPP_rngScope_gen;
            rcpp_result_gen = p_nbLookupIPaddrs(Shield<SEXP>(Rcpp::wrap(nbt)), Shield<SEXP>(Rcpp::wrap(IPaddrStrings)));
        }
        if (rcpp_result_gen.inherits("interrupted-error"))
            throw Rcpp::internal::InterruptedException();
        if (rcpp_result_gen.inherits("try-error"))
            throw Rcpp::exception(as<std::string>(rcpp_result_gen).c_str());
        return Rcpp::as<DataFrame >(rcpp_result_gen);
    }

}

#endif // RCPP_netblockr_RCPPEXPORTS_H_GEN_
