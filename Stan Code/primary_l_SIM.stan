//---------------------------------------------//
  //  rstan model for Plasma primary analysis  //
  //    (with alpha)                              //
  //   author:                KSG/DW             //
  //   last modified date:    10/05/2020         //
  //                                             //
  //---------------------------------------------//
  
  data {
    int<lower=0> N;                // number of observations
    int<lower=2> L;                // number of WHO categories
    int<lower=1> K;                // number of studies
    int<lower=0,upper=1> y_2[N];     // vector of categorical outcomes
    int<lower=1,upper=K> kk[N];    // site for individual
    int<lower=0,upper=1> ctrl[N];  // treatment or control
    int<lower=1,upper=3> cc[K];    // specific control for site
             
    
    real<lower=0> prior_div;    // prior sd
    real<lower=0> prior_Delta_sd;  // prior sd
    real<lower=0> eta;             // sd of delta  (around Delta)
    real<lower=0> prior_eta_0;
   
    
  }

parameters {
  
  real tau[K];      // cut-points for cumulative odds model
  
  real<lower=0>  eta_0;     // sd of delta_k (around delta)
  
  
  // non-central parameterization
  
  vector[K] z_ran_rx;      // RCT-specific effect 
  vector[3] z_delta;
 
  real z_Delta;
}

transformed parameters{ 
  
  vector[3] delta;          // control-specific effect
  vector[K] delta_k;        // site specific treatment effect
  vector[N] yhat;
        
  real Delta;
  
  Delta = prior_Delta_sd * z_Delta;
  delta = eta * z_delta + Delta;
 
  
  for (k in 1:K)
    delta_k[k] = eta_0 * z_ran_rx[k] + delta[cc[k]]; 
  
  for (i in 1:N)  
    yhat[i] = tau[kk[i]] + ctrl[i] * delta_k[kk[i]];
}

model {
  
  // priors
  z_ran_rx ~ std_normal(); 
  z_delta ~ std_normal();

  z_Delta ~ std_normal();
    
  eta_0 ~ student_t(3,0,prior_eta_0);
  
  for (k in 1:K)
      tau[k] ~ student_t(3, 0, prior_div);
  
  // outcome model
  
  for (i in 1:N)
    y_2[i] ~ bernoulli_logit(yhat[i]);
}

generated quantities {
  
  real OR;
  
  OR = exp(-Delta); 
  
}
