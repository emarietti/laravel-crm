<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        //
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        // Use Base64 encoding instead of encryption for the DIALER_API_TOKEN
        $encodedToken = base64_encode(config('services.dialer.api_token'));

        view()->composer('*', function ($view) use ($encodedToken) {
            $view->with('dialerApiToken', $encodedToken);
        });
    }
}
