const rr = "round_robin",
    single = "single_elimination",
    double = "double_elimination";
const first = "first_stage",
    second = "second_stage";
const single_stage = "single_stage",
    two_stage = "two_stage";
module.exports = {
    tournament_format:{
        rr:rr,
        single:single,
        double:double
    },
    tournament_stage:{
        first:first,
        second:second
    },
    num_stages:{
        single_stage:single_stage,
        two_stage:two_stage
    }
};