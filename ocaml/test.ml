open Ralg

let ralg_options = default_options ()

let test_abs() =
  let x0 = Float.Array.make 2 1000. in

  let sign = function x when x < 0. -> -1. | _ -> 1. in
  let f_obj x =
    let x0 = Float.Array.get x 0 in
    let x1 = Float.Array.get x 1 in
    ( abs_float ( x0-.3. ) ) +. 100.*.( abs_float( x0+.2.) ) +. 0.001*.( abs_float x1 ) in
  let f_grad x =
    let x0 = Float.Array.get x 0 in
    let x1 = Float.Array.get x 1 in
    let g0 = ( sign ( x0-.3. ) ) +. 100.*.( sign ( x0 +. 2. ) ) in
    let g1 = 0.001*.(sign x1) in
    let res = Float.Array.create 2 in
    Float.Array.set res 0 g0;
    Float.Array.set res 1 g1;
    res
  in
  let f_cb x = Some ( (f_obj x), (f_grad x) ) in
  let opt_obj, opt_x = ralg ralg_options f_cb x0 in
  Printf.printf "OCaml side: optimal objective %f, optimal point is %f, %f\n" opt_obj (Float.Array.get opt_x 0) (Float.Array.get opt_x 1);
  if abs_float (opt_obj -. 5.) < 1.e-10 then
    Printf.printf "TEST OK\n"
  else
    Printf.printf "----------- TEST FAILED at %f ----------\n" opt_obj

let () = test_abs()
