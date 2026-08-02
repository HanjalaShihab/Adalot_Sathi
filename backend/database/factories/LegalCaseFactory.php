<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\LegalCase>
 */
class LegalCaseFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'title' => fake()->randomElement([
                'Title Suit for Partition',
                'Criminal Trespass Case',
                'Money Loan Recovery Suit',
                'Specific Performance of Contract',
                'Divorce and Maintenance Petition',
                'Writ Petition (Certiorari)',
                'Cheque Dishonour Case',
                'Land Boundary Dispute',
                'Tortious Claim for Damages',
                'Family Custody Petition',
            ]),
            'case_number' => fake()->randomElement([
                'Civil Suit No. 145 of 2024',
                'C.R. Case No. 823 of 2024',
                'Money Suit No. 66 of 2023',
                'W.P. No. 5412 of 2024',
                'Title Appeal No. 210 of 2023',
                'Criminal Appeal No. 98 of 2024',
                'Execution Case No. 332 of 2024',
                'Arbitration Case No. 17 of 2025',
            ]),
            'client_name' => fake()->randomElement([
                'Md. Abdul Karim',
                'Fatema Begum',
                'Rafiqul Islam',
                'Nusrat Jahan',
                'Shahidul Alam',
                'Ayesha Siddiqua',
                'Mizanur Rahman',
                'Tahmina Akter',
                'Kamal Hossain',
                'Shirin Sultana',
            ]),
            'client_phone' => '01' . fake()->numberBetween(3, 9) . fake()->numerify('########'),
            'court_name' => fake()->randomElement([
                'Dhaka District Judge Court',
                'Chief Metropolitan Magistrate Court, Dhaka',
                'Civil Judge Court, Chattogram',
                'Family Court, Dhaka',
                'High Court Division, Dhaka',
                'District Court, Rajshahi',
                'Metropolitan Sessions Court, Dhaka',
                'Joint District Judge Court, Khulna',
            ]),
            'opposing_party' => fake()->randomElement([
                'Md. Golam Mostofa',
                'Mrs. Roksana Parvin',
                'Bangladesh Bank',
                'City Corporation, Dhaka',
                'Md. Jahangir Alam',
                'Rupali Bank Limited',
                'Md. Selim Chowdhury',
                'National Housing Authority',
            ]),
            'case_type' => fake()->randomElement([
                'Civil',
                'Criminal',
                'Family',
                'Labour',
                'Revenue',
                'Constitutional',
                'Arbitration',
                'Banking',
            ]),
            'status' => fake()->randomElement(['active', 'active', 'active', 'on_hold', 'closed']),
            'notes' => fake()->optional()->sentence(10),
        ];
    }

    /**
     * Keep only active cases.
     */
    public function active(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'active',
        ]);
    }
}

