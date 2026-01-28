#include <Rcpp.h>
#include <vector>
#include <string>
#include <algorithm>

using namespace Rcpp;

// Helper function for Levenshtein logic
int single_lev(std::string s1, std::string s2) {
    int n1 = s1.length();
    int n2 = s2.length();
    if (n1 == 0) return n2;
    if (n2 == 0) return n1;
    std::vector<int> prev(n2 + 1);
    std::vector<int> curr(n2 + 1);
    for (int j = 0; j <= n2; j++) prev[j] = j;
    for (int i = 1; i <= n1; i++) {
        curr[0] = i;
        for (int j = 1; j <= n2; j++) {
            int cost = (s1[i - 1] == s2[j - 1]) ? 0 : 1;
            curr[j] = std::min({ curr[j - 1] + 1, prev[j] + 1, prev[j - 1] + cost });
        }
        prev = curr;
    }
    return prev[n2];
}

// [[Rcpp::export]]
NumericVector cpp_levenshtein_vec(StringVector queries, std::string ref) {
    int n = queries.size();
    NumericVector res(n);
    for(int i = 0; i < n; ++i) {
        res[i] = single_lev(as<std::string>(queries[i]), ref);
    }
    return res;
}

// [[Rcpp::export]]
NumericVector nw_align_score(StringVector queries, std::string ref, 
                             int match = 1, int mismatch = -3, int gap = -5) {
    int n = ref.length();
    int num_queries = queries.size();
    NumericVector scores(num_queries);
    for (int q = 0; q < num_queries; ++q) {
        std::string query = as<std::string>(queries[q]);
        int m = query.length();
        std::vector<int> prev(m + 1);
        std::vector<int> curr(m + 1);
        for (int j = 0; j <= m; ++j) prev[j] = j * gap;
        for (int i = 1; i <= n; ++i) {
            curr[0] = i * gap;
            for (int j = 1; j <= m; ++j) {
                int score_match = prev[j - 1] + (ref[i - 1] == query[j - 1] ? match : mismatch);
                int score_del = prev[j] + gap;
                int score_ins = curr[j - 1] + gap;
                curr[j] = std::max({score_match, score_del, score_ins});
            }
            prev = curr;
        }
        scores[q] = prev[m];
    }
    return scores;
}