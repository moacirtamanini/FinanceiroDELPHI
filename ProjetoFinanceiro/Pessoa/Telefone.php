<?php namespace EPlacas\Pessoa;

use EPlacas\Model;
use Illuminate\Database\Eloquent\SoftDeletingTrait;

class Telefone extends Model
{
    use SoftDeletingTrait;

    /**
     * The database table used by the model.
     *
     * @var string
     */
    protected $table = 'Bludata.Telefone';

    /**
     * Primary key of table
     * @var string
     */
    protected $primaryKey = 'Id';

    /**
     * Campos que podem ser instanciados com mass-assignable
     * @var array
     */
    protected $fillable = [
        'ddd',
        'numero',
        'ramal',
        'tipo',
        'contato',
        'PessoaId'
    ];

    protected $guarded = [];

    protected $dates = ['deleted_at'];

    public static function name()
    {
        return 'Telefone';
    }
    /**
     * Regras de validação
     * @var array
     */
    public function storeRules()
    {
        return [
            'ddd'      => 'required|size:2',
            'numero'   => 'required|min:7|max:15',
            'tipo'     => 'required|in:D,C,O'//Doméstico,Celular,Comercial
        ];
    }

    public function updateRules()
    {
        return $this->storeRules();
    }

    public function getDescriptionAttribute()
    {
        return sprintf('(%u) %u', $this->attributes['ddd'], $this->attributes['numero']);
    }

    /**
     * Telefone tem um estado
     * @return Estado
     */
    public function pessoa()
    {
        return $this->belongsTo('EPlacas\Pessoa\Pessoa', 'PessoaId', 'Id');
    }
}
