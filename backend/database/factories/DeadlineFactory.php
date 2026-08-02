<?php

namespace Database\Factories;

use App\Models\LegalCase;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Deadline>
 */
class DeadlineFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'case_id' => LegalCase::factory(),
            'title' => fake()->randomElement([
                'Hearing for ad-interim injunction',
                'Filing of written statement',
                'Appeal submission deadline',
                'Witness examination',
                'Date for judgment',
                'Cross-examination of PW-1',
                'Filing of rejoinder',
                'Compliance hearing',
                'Deposit of decretal amount',
                'Submission of expert report',
            ]),
            'event_type' => fake()->randomElement(['hearing', 'hearing', 'filing', 'appeal', 'other']),
            'due_date' => fake()->dateTimeBetween('-7 days', '+60 days')->format('Y-m-d'),
            'due_time' => fake()->randomElement(['10:00', '11:00', '10:30', '12:00', '14:00', null]),
            'description' => fake()->optional()->sentence(12),
            'status' => 'pending',
            'reminder_days_before' => [7, 3, 1],
        ];
    }

    /**
     * Mark the deadline as completed.
     */
    public function completed(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'completed',
        ]);
    }

    /**
     * Set a due date relative to today (for deterministic tests).
     */
    public function dueOn(string $date): static
    {
        return $this->state(fn (array $attributes) => [
            'due_date' => $date,
        ]);
    }
}

