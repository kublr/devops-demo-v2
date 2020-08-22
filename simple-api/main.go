package main

import (
	"fmt"
	"io"
	"io/ioutil"
	"math/rand"
	"net/http"
	"os"
	"strconv"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func index(w http.ResponseWriter, r *http.Request) {
	if rand.Int63n(100) < errRate {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	bs, err := ioutil.ReadFile("./content/index.html")

	if err != nil {
		fmt.Printf("Couldn't read index.html: %v", err)
		os.Exit(1)
	}

	io.WriteString(w, string(bs[:]))
}

func healthz(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	io.WriteString(w, "ok")
}

var errRate int64 = 0

func main() {
	failRate := os.Getenv("FAIL_RATE")
	if failRate != "" {
		var err error

		errRate, err = strconv.ParseInt(failRate, 10, 64)
		if err != nil {
			fmt.Println(err)
		}
	}

	http.Handle("/", instrumentHandler("/", index))
	http.Handle("/healthz", instrumentHandler("healthz", healthz))
	http.Handle("/metrics", promhttp.Handler())

	port := ":8000"

	fmt.Printf("Starting to service on port %s\n", port)

	http.ListenAndServe(port, nil)
}

func instrumentHandler(name string, handler http.HandlerFunc) http.HandlerFunc {
	return promhttp.InstrumentHandlerDuration(duration.MustCurryWith(prometheus.Labels{"handler": name}),
		promhttp.InstrumentHandlerCounter(counter,
			handler,
		),
	)
}

var (
	counter  *prometheus.CounterVec
	duration *prometheus.HistogramVec
)

func init() {
	counter = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "api_requests_total",
			Help: "A counter for requests to the wrapped handler.",
		},
		[]string{"code", "method"},
	)

	// duration is partitioned by the HTTP method and handler. It uses custom
	// buckets based on the expected request duration.
	duration = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "request_duration_seconds",
			Help:    "A histogram of latencies for requests.",
			Buckets: []float64{.25, .5, 1, 2.5, 5, 10},
		},
		[]string{"handler", "method"},
	)

	prometheus.MustRegister(counter, duration)
}
