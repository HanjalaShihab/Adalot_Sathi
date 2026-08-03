<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\User>
 */
class UserFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->name('en_BD'),
            'email' => fake()->unique()->safeEmail(),
            'phone' => '01' . fake()->numberBetween(3, 9) . fake()->numerify('########'),
            'email_verified_at' => now(),
            'password' => static::$password ??= Hash::make('password'),
            'remember_token' => Str::random(10),
'role' => 'lawyer',
            'subscription_tier' => 'free',
            'subscription_expires_at' => null,
            'bar_council_number' => (string) fake()->numberBetween(1000, 9999),
            'chamber_name' => fake()->randomElement([
                'Tanvir & Associates',
                'Justice Chambers',
                'Advocate Group, Dhaka',
                'Law & Equity Chambers',
            ]),
            'address' => fake()->address(),
            'district' => fake()->randomElement([
                'Dhaka', 'Chattogram', 'Rajshahi', 'Khulna', 'Sylhet', 'Barishal',
            ]),
            'profile_photo' => null,
            'years_of_experience' => fake()->numberBetween(1, 35),
            'practice_areas' => fake()->randomElements([
                'Criminal', 'Civil', 'Family', 'Corporate', 'Property', 'Tax',
            ], rand(1, 3)),
            'preferred_court' => fake()->randomElement([
                'Dhaka District Court',
                'High Court Division',
                'Metropolitan Sessions Court',
                'Family Court',
            ]),
            'app_language' => 'bn',
            'notification_settings' => [
                'push' => true,
                'sms' => false,
                'email' => true,
            ],
            'reminder_settings' => [
                'default_days' => [7, 3, 1],
            ],
            'dark_mode' => false,
        ];
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }

    /**
     * Set the user as a super admin.
     */
    public function admin(): static
    {
        return $this->state(fn (array $attributes) => [
            'role' => 'admin',
            'subscription_tier' => 'paid',
            'subscription_expires_at' => now()->addYear()->toDateString(),
        ]);
    }

    /**
     * Set the user as a paid subscriber.
     */
    public function paid(): static
    {
        return $this->state(fn (array $attributes) => [
            'subscription_tier' => 'paid',
            'subscription_expires_at' => now()->addYear()->toDateString(),
        ]);
    }
}

