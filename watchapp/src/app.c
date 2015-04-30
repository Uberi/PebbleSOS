#include "pebble.h"

#define COUNTDOWN_DURATION 20

const char NORMAL_INFO[] = "SHAKE TO SEND ALERT MESSAGE";
const char SHAKEN_INFO[] = "PRESS ANY BUTTON TO CANCEL";
const char SENT_INFO[] = "MESSAGE SENT SUCCESSFULLY";

static Window *main_window;
static TextLayer *info_layer, *countdown_layer;

static void launch_background_worker(void) {
    if (app_worker_is_running()) return; // already running
    switch (app_worker_launch()) {
        case APP_WORKER_RESULT_SUCCESS: break;
        case APP_WORKER_RESULT_NO_WORKER: text_layer_set_text(info_layer, "NO WORKER"); break;
        case APP_WORKER_RESULT_NOT_RUNNING: text_layer_set_text(info_layer, "WORKER NOT RUNNING"); break;
        case APP_WORKER_RESULT_ALREADY_RUNNING: text_layer_set_text(info_layer, "ALREADY RUNNING WORKER"); break;
        case APP_WORKER_RESULT_DIFFERENT_APP: text_layer_set_text(info_layer, "WORKER IN OTHER APP"); break;
        case APP_WORKER_RESULT_ASKING_CONFIRMATION: text_layer_set_text(info_layer, "WORKER PENDING PERMISSION"); break;
        default: text_layer_set_text(info_layer, "UNKNOWN WORKER ERROR"); break;
    }
}

// message sending
bool check_appmessage_result(AppMessageResult result) {
    switch (result) {
        case APP_MSG_OK: return true;
        case APP_MSG_SEND_TIMEOUT: text_layer_set_text(info_layer, "MESSAGE SEND TIMEOUT"); return false;
        case APP_MSG_SEND_REJECTED: text_layer_set_text(info_layer, "MESSAGE REJECTED"); return false;
        case APP_MSG_NOT_CONNECTED: text_layer_set_text(info_layer, "NOT CONNECTED"); return false;
        case APP_MSG_APP_NOT_RUNNING: text_layer_set_text(info_layer, "APP NOT RUNNING"); return false;
        case APP_MSG_INVALID_ARGS: text_layer_set_text(info_layer, "INVALID MESSAGE ARGS"); return false;
        case APP_MSG_BUSY: text_layer_set_text(info_layer, "MESSAGE PENDING"); return false;
        case APP_MSG_BUFFER_OVERFLOW: text_layer_set_text(info_layer, "MESSAGE BUFFER OVERFLOW"); return false;
        case APP_MSG_ALREADY_RELEASED: text_layer_set_text(info_layer, "MESSAGE ALREADY RELEASED"); return false;
        case APP_MSG_CALLBACK_ALREADY_REGISTERED: text_layer_set_text(info_layer, "CALLBACK ALREADY REGISTERED"); return false;
        case APP_MSG_CALLBACK_NOT_REGISTERED: text_layer_set_text(info_layer, "NO CALLBACK REGISTERED"); return false;
        case APP_MSG_OUT_OF_MEMORY: text_layer_set_text(info_layer, "OUT OF MEMORY"); return false;
        case APP_MSG_CLOSED: text_layer_set_text(info_layer, "APP MESSAGE CLOSED"); return false;
        case APP_MSG_INTERNAL_ERROR: text_layer_set_text(info_layer, "INTERNAL ERROR"); return false;
        default: text_layer_set_text(info_layer, "UNKNOWN MESSAGING ERROR"); return false;
    }
}
void on_send_success(DictionaryIterator *sent, void *context) { text_layer_set_text(info_layer, SENT_INFO); }
static void on_send_failed(DictionaryIterator *failed, AppMessageResult reason, void* context) { check_appmessage_result(reason); }
static void send_alert_to_phone() {
    app_message_register_outbox_sent(on_send_success);
    app_message_register_outbox_failed(on_send_failed);
    app_message_open(32, 32);
    DictionaryIterator *iter;
    if (!check_appmessage_result(app_message_outbox_begin(&iter))) return;
    static uint8_t outbox_buffer[50];
    if (dict_write_begin(iter, outbox_buffer, 50) != DICT_OK) { text_layer_set_text(info_layer, "CAN'T BEGIN DICTIONARY"); return; }
    if (dict_write_end(iter) == 0) { text_layer_set_text(info_layer, "CAN'T END DICTIONARY"); return; }
    if (!check_appmessage_result(app_message_outbox_send())) return;
}

// countdown management
static bool is_counting = false;
static int current_countdown;
static void update_countdown(int value) {
    if (value > 0) { // counting down
        static char buff[8]; snprintf(buff, sizeof(buff), "%d", value);
        text_layer_set_text(countdown_layer, buff);
    } else if (value < 0) // not counting down
        text_layer_set_text(countdown_layer, "--");
    else { // countdown expired
        text_layer_set_text(countdown_layer, "sent");
        send_alert_to_phone();
    }
}
static void countdown_timer_callback(void *data);
static void start_countdown(int duration) {
    if (is_counting) return; is_counting = true;
    vibes_double_pulse();
    text_layer_set_text(info_layer, SHAKEN_INFO);
    current_countdown = duration;
    update_countdown(current_countdown);
    app_timer_register(1000, countdown_timer_callback, NULL);
}
static void stop_countdown(void) {
    if (!is_counting) return; is_counting = false;
    text_layer_set_text(info_layer, NORMAL_INFO);
    vibes_long_pulse();
}
static void countdown_timer_callback(void *data) {
    if (!is_counting) return; // counting stopped while timer was running
    current_countdown --;
    if (current_countdown <= 0) {
        stop_countdown(); update_countdown(0);
        return;
    }
    update_countdown(current_countdown);
    app_timer_register(1000, countdown_timer_callback, NULL);
}

// button press action and shake actions
static void click_handler(ClickRecognizerRef recognizer, void *context) {
    if (is_counting) { stop_countdown(); update_countdown(-1); }
    else start_countdown(COUNTDOWN_DURATION);
}
static void click_config_provider(void *context) {
    window_single_click_subscribe(BUTTON_ID_UP, click_handler);
    window_single_click_subscribe(BUTTON_ID_SELECT, click_handler);
    window_single_click_subscribe(BUTTON_ID_DOWN, click_handler);
}
static void worker_message_handler(uint16_t type, AppWorkerMessage *data) { start_countdown(COUNTDOWN_DURATION); }

// graphics
static void main_window_load(Window *window) {
    Layer *window_layer = window_get_root_layer(window); GRect bounds = layer_get_bounds(window_layer);

    info_layer = text_layer_create(GRect(5, 5, bounds.size.w - 10, 60));
    text_layer_set_text(info_layer, NORMAL_INFO);
    text_layer_set_font(info_layer, fonts_get_system_font(FONT_KEY_GOTHIC_24));
    text_layer_set_text_alignment(info_layer, GTextAlignmentCenter);
    layer_add_child(window_layer, text_layer_get_layer(info_layer));

    countdown_layer = text_layer_create(GRect(5, 75, bounds.size.w - 10, bounds.size.h - 55));
    text_layer_set_font(countdown_layer, fonts_get_system_font(FONT_KEY_BITHAM_42_BOLD));
    text_layer_set_text_alignment(countdown_layer, GTextAlignmentCenter);
    text_layer_set_background_color(countdown_layer, GColorBlack);
    text_layer_set_text_color(countdown_layer, GColorWhite);
    layer_add_child(window_layer, text_layer_get_layer(countdown_layer));
    update_countdown(-1);

    launch_background_worker();
}
static void main_window_unload(Window *window) {
    text_layer_destroy(info_layer);
}

static void init(void) {
    main_window = window_create();
    window_set_background_color(main_window, GColorBlack);
    window_set_window_handlers(main_window, (WindowHandlers) { .load = main_window_load, .unload = main_window_unload });
    window_stack_push(main_window, true);

    window_set_click_config_provider(main_window, click_config_provider); // register button click config
    app_worker_message_subscribe(worker_message_handler); // register shake handler
    
    if (launch_reason() == APP_LAUNCH_WORKER) // launched because the worker started the app
        start_countdown(COUNTDOWN_DURATION);
}

static void deinit(void) {
    app_worker_message_unsubscribe();
    window_destroy(main_window);
}

int main(void) {
    init();
    app_event_loop();
    deinit();
}
