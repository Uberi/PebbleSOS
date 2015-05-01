#include <pebble_worker.h>

#define SHAKE_THRESHOLD 1500
#define RESET_THRESHOLD 500

DataLoggingSessionRef data_logger;

void on_shake(void) {
    worker_launch_app();
    AppWorkerMessage msg_data = { .data0 = 0 };
    app_worker_send_message(0, &msg_data);
}

bool is_shaking = false;
static void data_handler(AccelData *data, uint32_t num_samples) {
    if (is_shaking) {
        if (data[0].x < RESET_THRESHOLD) is_shaking = false;
        return;
    }
    if (data[0].x > SHAKE_THRESHOLD) {
        is_shaking = true;
        on_shake();
    }
}

static void worker_init() {
    accel_data_service_subscribe(1, data_handler);
    accel_service_set_sampling_rate(ACCEL_SAMPLING_10HZ);
}

static void worker_deinit() {
    accel_data_service_unsubscribe();
}

int main(void) {
    worker_init();
    worker_event_loop();
    worker_deinit();
}
