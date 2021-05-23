

//60 Hz notch filter, 2nd Order Butterworth: [b, a] = butter(2,[59.0 61.0]/(fs_Hz / 2.0), 'stop') %matlab command
//// Fs 125Hz
//b2 = new double[] { 0.931378858122982, 3.70081291785747, 5.53903191270520, 3.70081291785747, 0.931378858122982 };
//a2 = new double[] { 1, 3.83246204081167, 5.53431749515949, 3.56916379490328, 0.867472133791669 };
//// Fs 200Hz
//double[] notch_b2 = new double[] { 0.956543225556877, 1.18293615779028, 2.27881429174348, 1.18293615779028, 0.956543225556877 };
//double[] notch_a2 = new double[] { 1, 1.20922304075909, 2.27692490805580, 1.15664927482146, 0.914975834801436 };
//double[] notch_b1 = new double[] { 0.781367265547444, 1.94025704064504, 4.93220461557345, 6.56850558104815, 8.41772104541325, 6.56850558104815, 4.93220461557345, 1.94025704064504, 0.781367265547443 };
//double[] notch_a1 = new double[] { 1, 2.33037581858861, 5.54685203036105, 6.94132404071813, 8.35204672387189, 6.13649425941098,  4.33543124586087, 1.60933112466866, 0.610534807561225 };
//// Fs 250Hz
double[] notch_b1 = new double[] { 0.876853889673250,  -0.441021920093838,  3.59059660642537,  -1.33003854214373,  5.42770462264748,  -1.33003854214373,  3.59059660642537,  -0.441021920093838,  0.876853889673250 };
double[] notch_a1 = new double[] { 1,  -0.486446842673056,  3.82612175518261,  -1.37173503752132,  5.41234500239064,  -1.28453119082115,  3.35526611340481,  -0.399407853459589,  0.768872743866654 };
double[] notch_b2 = new double[] { 0.965080986344733, -0.242468320175764, 1.94539149412878, -0.242468320175764, 0.965080986344733 };
double[] notch_a2 = new double[] { 1, -0.246778261129785, 1.94417178469135, -0.238158379221743, 0.931381682126902 };
//// Fs 500Hz
//b2 = new double[] { 0.982385438526095, -2.86473884662109, 4.05324051877773, -2.86473884662109, 0.982385438526095};
//a2 = new double[] { 1, -2.89019558531207, 4.05293022193077, -2.83928210793009, 0.965081173899134 };
//// Fs 1000Hz
//b2 = new double[] { 0.991153595101611, -3.68627799048791, 5.40978944177152, -3.68627799048791, 0.991153595101611 };
//a2 = new double[] { 1, -3.70265590760266, 5.40971118136100, -3.66990007337352, 0.982385450614122 };
//// Fs 1600Hz
//b2 = new double[] { 0.994461788958027, -3.86796874670208, 5.75004904085114, -3.86796874670208, 0.994461788958027 };
//a2 = new double[] { 1, -3.87870938463296, 5.75001836883538, -3.85722810877252, 0.988954249933128 };
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/** Alpha **/
//// Fs 200Hz
double[] alpha_b = new double[] { 0.000699349649904283, 0, -0.00209804894971285, 0, 0.00209804894971285, 0, -0.000699349649904283 };
double[] alpha_a = new double[] { 1, -5.37215741516161, 12.2621401138342, -15.2095187310247, 10.8104688242883, -4.17587701696822, 0.685535977284666 };

void filterIIR(double[] filt_b, double[] filt_a, float[] raw_data, float[] filt_data) {
    int Nback = filt_b.length;
    double[] prev_y = new double[Nback];
    double[] prev_x = new double[Nback];

    //step through data points
    for (int i = 0; i < raw_data.length; i++) {
        //shift the previous outputs
        for (int j = Nback-1; j > 0; j--) {
            prev_y[j] = prev_y[j-1];
            prev_x[j] = prev_x[j-1];
        }

        //add in the new point
        prev_x[0] = raw_data[i];

        //compute the new data point
        double out = 0;
        for (int j = 0; j < Nback; j++) {
            out += filt_b[j]*prev_x[j];
            if (j > 0) {
                out -= filt_a[j]*prev_y[j];
            }
        }

        //save output value
        prev_y[0] = out;
        if(i>128){
          filt_data[i-128] = (float)out;
        }
    }
}